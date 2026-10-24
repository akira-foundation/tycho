import Foundation

public enum CalendarItem: Identifiable {
    case event(CalendarEvent)
    case task(TaskItem)

    public var id: UUID {
        switch self {
        case .event(let event): event.id
        case .task(let task): task.id
        }
    }
}

public struct CalendarChips {
    public let shown: [CalendarItem]
    public let overflow: Int
}

public enum CalendarDay {
    public static let chipLimit = 3

    public static func items(
        on day: Date, events: [CalendarEvent], tasks: [TaskItem], calendar: Calendar
    )
        -> [CalendarItem]
    {
        let onDay: (Date?) -> Bool = { date in date.map { calendar.isDate($0, inSameDayAs: day) } ?? false }
        let dayEvents = events.filter { onDay($0.date) }.sorted { $0.time < $1.time }
        let dayTasks = tasks.filter { onDay($0.due) }.sorted { lhs, rhs in
            (lhs.project?.sortOrder ?? 0, lhs.sortOrder) < (rhs.project?.sortOrder ?? 0, rhs.sortOrder)
        }
        return dayEvents.map(CalendarItem.event) + dayTasks.map(CalendarItem.task)
    }

    public static func chips(for items: [CalendarItem]) -> CalendarChips {
        CalendarChips(shown: Array(items.prefix(chipLimit)), overflow: max(0, items.count - chipLimit))
    }
}
