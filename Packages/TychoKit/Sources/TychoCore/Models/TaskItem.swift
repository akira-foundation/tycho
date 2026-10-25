import Foundation
import SwiftData

@Model
public final class TaskItem {
    public var id: UUID = UUID()
    public var number: Int = 0
    public var title: String = ""
    public var statusRaw: String = TaskStatus.todo.rawValue
    public var priorityRaw: String = TaskPriority.noPriority.rawValue
    public var labelsRaw: [String] = []
    public var start: Date?
    public var due: Date?
    public var estimate: String?
    public var notes: String = ""
    public var sortOrder: Double = 0
    public var isFavorite: Bool = false
    public var createdAt: Date = Date.now
    public var updatedAt: Date = Date.now
    public var completedAt: Date?
    public var project: Project?
    public var assignee: Member?
    @Relationship(deleteRule: .cascade, inverse: \Subtask.task) public var subtasks: [Subtask]? = []

    public init(number: Int, title: String) {
        self.number = number
        self.title = title
    }

    public var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .todo }
        set { statusRaw = newValue.rawValue }
    }

    public var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .noPriority }
        set { priorityRaw = newValue.rawValue }
    }

    public var labels: Set<TaskLabel> {
        get { Set(labelsRaw.compactMap(TaskLabel.init(rawValue:))) }
        set { labelsRaw = TaskLabel.allCases.filter(newValue.contains).map(\.rawValue) }
    }

    public var key: String { "\(project?.key ?? "")-\(number)" }

    public var orderedSubtasks: [Subtask] { (subtasks ?? []).sorted { $0.sortOrder < $1.sortOrder } }
}
