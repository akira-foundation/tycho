import Foundation

public enum TaskFilterField: String, Codable, CaseIterable, Sendable {
    case status
    case assignee
    case priority
    case due
    case project
    case labels
    case created
    case updated
    case completed

    public var title: String {
        switch self {
        case .status: "Status"
        case .assignee: "Assignee"
        case .priority: "Priority"
        case .due: "Due date"
        case .project: "Project"
        case .labels: "Labels"
        case .created: "Created date"
        case .updated: "Updated date"
        case .completed: "Completed date"
        }
    }

    public var symbol: String {
        switch self {
        case .status: "circle.dotted"
        case .assignee: "person"
        case .priority: "chart.bar"
        case .due: "calendar"
        case .project: "folder"
        case .labels: "tag"
        case .created: "calendar.badge.plus"
        case .updated: "clock.arrow.circlepath"
        case .completed: "checkmark.circle"
        }
    }
}

public enum TaskFilterOperator: String, Codable, CaseIterable, Sendable {
    case `is` = "is"
    case isNot

    public var title: String {
        switch self {
        case .is: "is"
        case .isNot: "is not"
        }
    }
}

public struct TaskFilter: Codable, Hashable, Sendable {
    public static let noAssignee = "none"

    public var field: TaskFilterField
    public var op: TaskFilterOperator
    public var values: [String]

    public static let completedThisWeek = [
        TaskFilter(field: .status, op: .is, values: [TaskStatus.done.rawValue]),
        TaskFilter(field: .completed, op: .is, values: [String(RecencyWindow.week.rawValue)]),
    ]

    public init(field: TaskFilterField, op: TaskFilterOperator = .is, values: [String] = []) {
        self.field = field
        self.op = op
        self.values = values
    }

    public func matches(_ task: TaskItem, now: Date, calendar: Calendar) -> Bool {
        guard !values.isEmpty else { return true }
        let hit = anyValueMatches(task, now: now, calendar: calendar)
        return op == .isNot ? !hit : hit
    }

    private func anyValueMatches(_ task: TaskItem, now: Date, calendar: Calendar) -> Bool {
        switch field {
        case .status: values.contains(task.statusRaw)
        case .priority: values.contains(task.priorityRaw)
        case .labels: values.contains { task.labelsRaw.contains($0) }
        case .assignee: values.contains(task.assignee?.id.uuidString ?? Self.noAssignee)
        case .project: task.project.map { values.contains($0.id.uuidString) } ?? false
        case .due:
            matchesDue(DueBucket.bucket(for: task, now: now, calendar: calendar))
        case .created: matchesRecency(task.createdAt, now: now)
        case .updated: matchesRecency(task.updatedAt, now: now)
        case .completed: task.completedAt.map { matchesRecency($0, now: now) } ?? false
        }
    }

    private func matchesDue(_ buckets: Set<DueBucket>) -> Bool {
        values.contains { DueBucket(rawValue: $0).map(buckets.contains) ?? false }
    }

    private func matchesRecency(_ date: Date, now: Date) -> Bool {
        values.contains { value in
            Int(value).flatMap(RecencyWindow.init(rawValue:)).map { date >= now - $0.interval } ?? false
        }
    }
}
