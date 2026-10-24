import Foundation

public struct DateText: Sendable {
    public static let monthNames = [
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
        "November", "December",
    ]
    public static let shortMonthNames = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ]
    public static let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    public let format: DateFormatPreference
    private let now: Date
    public let calendar: Calendar

    public static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    public init(format: DateFormatPreference = .monthDay, now: Date = .now, calendar: Calendar = DateText.gregorian) {
        self.format = format
        self.now = now
        self.calendar = calendar
    }

    public func short(_ date: Date) -> String { render(date, withYear: includesYear(date, long: false)) }

    public func long(_ date: Date) -> String { render(date, withYear: true) }

    func withoutYear(_ date: Date) -> String { render(date, withYear: false) }

    var yearSuffixPrefix: String {
        switch format {
        case .monthDay: ", "
        case .dayMonth, .monthDayNumeric: "/"
        case .iso: ""
        }
    }

    public func ago(_ date: Date) -> String {
        let minutes = Int((now.timeIntervalSince(date) / 60).rounded())
        let hours = Int((Double(minutes) / 60).rounded())
        let days = Int((Double(hours) / 24).rounded())
        switch (minutes, hours, days) {
        case (..<1, _, _): return "just now"
        case (..<60, _, _): return "\(minutes)m ago"
        case (_, ..<24, _): return "\(hours)h ago"
        case (_, _, ..<7): return "\(days)d ago"
        default: return short(date)
        }
    }

    private func includesYear(_ date: Date, long: Bool) -> Bool {
        long || calendar.component(.year, from: date) != calendar.component(.year, from: now)
    }

    private func render(_ date: Date, withYear: Bool) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let year = parts.year ?? 0
        let month = parts.month ?? 1
        let day = parts.day ?? 1
        switch format {
        case .monthDay: return "\(Self.shortMonthNames[month - 1]) \(day)" + (withYear ? ", \(year)" : "")
        case .dayMonth: return "\(day)/\(month)" + (withYear ? "/\(year)" : "")
        case .monthDayNumeric: return "\(month)/\(day)" + (withYear ? "/\(year)" : "")
        case .iso: return String(format: "%04d-%02d-%02d", year, month, day)
        }
    }
}
