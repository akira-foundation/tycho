public enum DateFormatPreference: String, CaseIterable, Codable, Sendable, Identifiable {
    case monthDay = "MMM d"
    case dayMonth = "d/M"
    case monthDayNumeric = "M/d"
    case iso = "yyyy-MM-dd"

    public var id: String { rawValue }

    public var example: String {
        switch self {
        case .monthDay: "Oct 1"
        case .dayMonth: "1/10"
        case .monthDayNumeric: "10/1"
        case .iso: "2026-10-01"
        }
    }
}
