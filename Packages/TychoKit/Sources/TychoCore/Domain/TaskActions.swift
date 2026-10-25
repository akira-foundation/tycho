import Foundation
import SwiftData

public struct TaskDraft {
    public var title: String
    public var status: TaskStatus
    public var priority: TaskPriority = .noPriority
    public var labels: Set<TaskLabel> = []
    public var assignee: Member?
    public var start: Date?
    public var due: Date?
    public var estimate: String?
    public var notes: String = ""

    public init(title: String, status: TaskStatus = .todo) {
        self.title = title
        self.status = status
    }
}

@MainActor
public struct TaskActions {
    private let context: ModelContext
    private let now: () -> Date

    public init(context: ModelContext, now: @escaping () -> Date = { .now }) {
        self.context = context
        self.now = now
    }

    public static func siblings(of status: TaskStatus, in project: Project?, excluding task: TaskItem?) -> [TaskItem] {
        (project?.tasks ?? [])
            .filter { $0.status == status && $0 !== task }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    @discardableResult
    public func create(_ draft: TaskDraft, in project: Project) throws -> TaskItem {
        let title = try Self.cleanTitle(draft.title)
        let task = TaskItem(number: project.nextTaskNumber, title: title)
        task.sortOrder = Rank.appendOrder(after: Self.siblings(of: draft.status, in: project, excluding: nil))
        task.status = draft.status
        task.priority = draft.priority
        task.labels = draft.labels
        task.start = draft.start
        task.due = draft.due
        task.estimate = draft.estimate
        task.notes = draft.notes
        task.createdAt = now()
        task.updatedAt = now()
        task.completedAt = draft.status == .done ? now() : nil
        context.insert(task)
        task.project = project
        task.assignee = draft.assignee
        project.nextTaskNumber += 1
        project.updatedAt = now()
        try context.saveOrRollback()
        return task
    }

    public func rename(_ task: TaskItem, to title: String) throws {
        task.title = try Self.cleanTitle(title)
        try touch(task)
    }

    public func edit(_ task: TaskItem, _ change: (TaskItem) -> Void) throws {
        change(task)
        try touch(task)
    }

    public func setStatus(_ task: TaskItem, _ status: TaskStatus) throws {
        guard task.status != status else { return }
        let siblings = Self.siblings(of: status, in: task.project, excluding: task)
        try move(task, to: status, at: siblings.count, among: siblings)
    }

    public func toggleDone(_ task: TaskItem) throws {
        try setStatus(task, task.status == .done ? .todo : .done)
    }

    public func move(_ task: TaskItem, to status: TaskStatus, at index: Int, among siblings: [TaskItem]) throws {
        if task.status != status {
            task.status = status
            task.completedAt = status == .done ? now() : nil
        }
        Rank.insert(task, into: siblings, at: index)
        try touch(task)
    }

    public func toggleFavorite(_ task: TaskItem) throws {
        task.isFavorite.toggle()
        try touch(task)
    }

    public func delete(_ task: TaskItem) throws {
        context.delete(task)
        try context.saveOrRollback()
    }

    static func cleanTitle(_ raw: String) throws -> String {
        let title = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw ValidationError.emptyTitle }
        return title
    }

    private func touch(_ task: TaskItem) throws {
        task.updatedAt = now()
        task.project?.updatedAt = now()
        try context.saveOrRollback()
    }
}
