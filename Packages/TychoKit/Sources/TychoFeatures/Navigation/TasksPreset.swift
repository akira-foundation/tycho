import TychoCore

public enum TasksPreset: Sendable {
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
}
