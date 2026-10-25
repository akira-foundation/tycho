public enum TaskLabel: String, CaseIterable, Codable, Sendable, Identifiable {
    case design
    case frontend
    case backend
    case research
    case content
    case bug
    case qa
    case growth

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .qa: "QA"
        default: rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }
}
