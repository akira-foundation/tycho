public enum TableColumnID: String, CaseIterable, Codable, Sendable, Identifiable {
    case title
    case status
    case priority
    case assignee
    case due
    case start
    case labels
    case deps
    case estimate
    case created
    case project

    public static let minimumWidth: Double = 64

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .title: "Task"
        case .status: "Status"
        case .priority: "Priority"
        case .assignee: "Assignee"
        case .due: "Due date"
        case .start: "Start date"
        case .labels: "Labels"
        case .deps: "Dependencies"
        case .estimate: "Estimate"
        case .created: "Created"
        case .project: "Project"
        }
    }

    public var defaultWidth: Double {
        switch self {
        case .title: 314
        case .status: 132
        case .priority, .due, .start, .created: 112
        case .assignee, .project: 156
        case .labels: 180
        case .deps: 150
        case .estimate: 92
        }
    }

    public var isHideable: Bool { self != .title }

    public var sortField: TaskSortField? {
        switch self {
        case .labels, .deps: nil
        default: TaskSortField(rawValue: rawValue)
        }
    }

    public static func defaultHidden(inProject: Bool) -> Set<TableColumnID> {
        inProject ? [.start, .created, .deps, .project] : [.start, .created, .deps]
    }
}
