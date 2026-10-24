import Foundation

public enum DayTime {
    public static func noon(of date: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .hour, value: 12, to: start) ?? start
    }

    public static func days(from start: Date, to end: Date, calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day
            ?? 0
    }
}
