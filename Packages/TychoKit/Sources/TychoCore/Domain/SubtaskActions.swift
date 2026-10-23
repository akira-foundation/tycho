import Foundation
import SwiftData

@MainActor
public struct SubtaskActions {
    private let context: ModelContext
    private let now: () -> Date

    public init(context: ModelContext, now: @escaping () -> Date = { .now }) {
        self.context = context
        self.now = now
    }

    @discardableResult
    public func add(_ title: String, to task: TaskItem) throws -> Subtask {
        let subtask = Subtask(title: try TaskActions.cleanTitle(title))
        subtask.sortOrder = Rank.appendOrder(after: task.orderedSubtasks)
        context.insert(subtask)
        subtask.task = task
        try touch(task)
        return subtask
    }

    public func toggle(_ subtask: Subtask) throws {
        subtask.isDone.toggle()
        try touch(subtask.task)
    }

    public func rename(_ subtask: Subtask, to title: String) throws {
        subtask.title = try TaskActions.cleanTitle(title)
        try touch(subtask.task)
    }

    public func move(_ subtask: Subtask, to index: Int) throws {
        let siblings = subtask.task?.orderedSubtasks.filter { $0 !== subtask } ?? []
        Rank.insert(subtask, into: siblings, at: index)
        try touch(subtask.task)
    }

    public func delete(_ subtask: Subtask) throws {
        let task = subtask.task
        context.delete(subtask)
        try touch(task)
    }

    private func touch(_ task: TaskItem?) throws {
        task?.updatedAt = now()
        try context.saveOrRollback()
    }
}
