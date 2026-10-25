public enum TaskPriority: String, CaseIterable, Codable, Sendable, Identifiable {
    case urgent
    case high
    case medium
    case low
    case noPriority = "none"

    public var id: String { rawValue }

    public var weight: Int {
        switch self {
        case .urgent: 4
        case .high: 3
        case .medium: 2
        case .low: 1
        case .noPriority: 0
        }
    }

    public var title: String {
        switch self {
        case .urgent: "Urgent"
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        case .noPriority: "No priority"
        }
    }
}
