public enum MemberRole: String, CaseIterable, Codable, Sendable, Identifiable {
    case owner
    case admin
    case member
    case guest

    public var id: String { rawValue }

    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}
