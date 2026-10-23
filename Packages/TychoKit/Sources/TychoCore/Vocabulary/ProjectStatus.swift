public enum ProjectStatus: String, CaseIterable, Codable, Sendable, Identifiable {
    case planning
    case active
    case risk
    case hold
    case complete

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .planning: "Planning"
        case .active: "In Progress"
        case .risk: "At Risk"
        case .hold: "On Hold"
        case .complete: "Completed"
        }
    }
}
