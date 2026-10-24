import Foundation

public enum CalendarMode: String, CaseIterable, Sendable, Identifiable {
    case month
    case week

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .month: "Month"
        case .week: "Week"
        }
    }
}

public struct CalendarCell: Hashable, Sendable, Identifiable {
    public let date: Date
    public let key: String
    public let day: Int
    public let weekday: Int
    public let isInMonth: Bool
    public let isToday: Bool

    public var id: String { key }
}

public enum CalendarGrid {
    public static func startOfWeek(_ date: Date, weekStart: WeekStart, calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: date)
        let offset = (calendar.component(.weekday, from: day) - weekStart.weekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: day) ?? day
    }

    public static func month(
        containing date: Date, weekStart: WeekStart, today: Date, calendar: Calendar
    )
        -> [CalendarCell]
    {
        let first = firstOfMonth(date, calendar: calendar)
        let month = calendar.component(.month, from: first)
        let start = startOfWeek(first, weekStart: weekStart, calendar: calendar)
        let cells = (0..<42).map { cell(at: $0, from: start, month: month, today: today, calendar: calendar) }
        return cells[35].isInMonth ? cells : Array(cells.prefix(35))
    }

    public static func week(
        containing date: Date, weekStart: WeekStart, today: Date, calendar: Calendar
    )
        -> [CalendarCell]
    {
        let start = startOfWeek(date, weekStart: weekStart, calendar: calendar)
        return (0..<7).map { cell(at: $0, from: start, month: nil, today: today, calendar: calendar) }
    }

    public static func weekdayLabels(weekStart: WeekStart) -> [String] {
        (0..<7).map { DateText.weekdayNames[(weekStart.weekday - 1 + $0) % 7] }
    }

    public static func title(
        _ mode: CalendarMode, anchor: Date, weekStart: WeekStart, format: DateFormatPreference = .monthDay,
        calendar: Calendar
    ) -> String {
        switch mode {
        case .month:
            let parts = calendar.dateComponents([.year, .month], from: anchor)
            return "\(DateText.monthNames[(parts.month ?? 1) - 1]) \(parts.year ?? 0)"
        case .week:
            let days = week(containing: anchor, weekStart: weekStart, today: anchor, calendar: calendar)
            let text = DateText(format: format, now: anchor, calendar: calendar)
            let last = days[6].date
            let year = calendar.component(.year, from: last)
            let suffix = format == .iso ? "" : "\(text.yearSuffixPrefix)\(year)"
            return "\(text.withoutYear(days[0].date)) – \(text.withoutYear(last))\(suffix)"
        }
    }

    public static func step(_ anchor: Date, mode: CalendarMode, by offset: Int, calendar: Calendar) -> Date {
        switch mode {
        case .month:
            calendar.date(byAdding: .month, value: offset, to: firstOfMonth(anchor, calendar: calendar)) ?? anchor
        case .week:
            calendar.date(byAdding: .day, value: 7 * offset, to: calendar.startOfDay(for: anchor)) ?? anchor
        }
    }

    private static func firstOfMonth(_ date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? calendar.startOfDay(for: date)
    }

    private static func cell(
        at offset: Int, from start: Date, month: Int?, today: Date, calendar: Calendar
    )
        -> CalendarCell
    {
        let date = calendar.date(byAdding: .day, value: offset, to: start) ?? start
        let parts = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        return CalendarCell(
            date: date,
            key: String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0),
            day: parts.day ?? 1,
            weekday: parts.weekday ?? 1,
            isInMonth: month.map { $0 == parts.month } ?? true,
            isToday: calendar.isDate(date, inSameDayAs: today)
        )
    }
}
