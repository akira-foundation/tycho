public enum ProjectColor: String, CaseIterable, Codable, Sendable, Identifiable {
    case indigo
    case blue
    case violet
    case teal
    case rose
    case amber
    case green
    case slate

    public var id: String { rawValue }

    public var hex: UInt32 {
        switch self {
        case .indigo: 0x5A67D8
        case .blue: 0x3B82C4
        case .violet: 0x8662C9
        case .teal: 0x23918A
        case .rose: 0xC54B78
        case .amber: 0xC48A1E
        case .green: 0x3D8E5F
        case .slate: 0x6B7280
        }
    }
}
