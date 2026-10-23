public enum TaskStatus: String, CaseIterable, Codable, Sendable, Identifiable {
    case backlog
    case todo
    case progress
    case review
    case done

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .backlog: "Backlog"
        case .todo: "To Do"
        case .progress: "In Progress"
        case .review: "Review"
        case .done: "Done"
        }
    }

    public var baselineProgress: Int {
        switch self {
        case .backlog: 0
        case .todo: 5
        case .progress: 45
        case .review: 80
        case .done: 100
        }
    }
}
