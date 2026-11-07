import TychoCore

public enum TasksPreset: CaseIterable, Sendable {
    case open
    case done
    case overdue

    public var filters: [TaskFilter] {
        switch self {
        case .open: [TaskFilter(field: .status, op: .isNot, values: [TaskStatus.done.rawValue])]
        case .done:
            [
                TaskFilter(field: .status, op: .is, values: [TaskStatus.done.rawValue]),
                TaskFilter(field: .updated, op: .is, values: ["7"]),
            ]
        case .overdue: [TaskFilter(field: .due, op: .is, values: [DueBucket.overdue.rawValue])]
        }
    }

    public var title: String {
        switch self {
        case .open: "Open Tasks"
        case .done: "Completed"
        case .overdue: "Overdue"
        }
    }

    public func subtitle(projectCount: Int) -> String {
        switch self {
        case .open: "Open tasks across \(projectCount) projects."
        case .done: "Tasks completed in the last 7 days across \(projectCount) projects."
        case .overdue: "Overdue tasks across \(projectCount) projects."
        }
    }

    public static func matching(_ filters: [TaskFilter]) -> TasksPreset? {
        allCases.first { $0.filters == filters }
    }
}
