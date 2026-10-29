public enum WeekStart: String, CaseIterable, Codable, Sendable, Identifiable {
    case monday
    case sunday
    case saturday

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .monday: "Monday"
        case .sunday: "Sunday"
        case .saturday: "Saturday"
        }
    }

    public var weekday: Int {
        switch self {
        case .monday: 2
        case .sunday: 1
        case .saturday: 7
        }
    }
}
