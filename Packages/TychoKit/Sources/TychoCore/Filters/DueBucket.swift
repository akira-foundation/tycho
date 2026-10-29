import Foundation

public enum DueBucket: String, CaseIterable, Sendable {
    case overdue
    case today
    case week
    case later
    case nodate

    public var title: String {
        switch self {
        case .overdue: "Overdue"
        case .today: "Today"
        case .week: "Next 7 days"
        case .later: "Later"
        case .nodate: "No due date"
        }
    }

    public static func bucket(for task: TaskItem, now: Date, calendar: Calendar) -> Set<DueBucket> {
        guard let due = task.due else { return [.nodate] }
        let days =
            calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: due)
            ).day ?? 0
        var buckets: Set<DueBucket> = []
        if days < 0 && task.status != .done { buckets.insert(.overdue) }
        if days == 0 { buckets.insert(.today) }
        if (0...7).contains(days) { buckets.insert(.week) }
        if days > 7 { buckets.insert(.later) }
        return buckets
    }
}

public enum RecencyWindow: Int, CaseIterable, Sendable {
    case day = 1
    case week = 7
    case month = 30

    public var title: String {
        switch self {
        case .day: "Last 24 hours"
        case .week: "Last 7 days"
        case .month: "Last 30 days"
        }
    }

    var interval: TimeInterval { TimeInterval(rawValue) * 86400 }
}
