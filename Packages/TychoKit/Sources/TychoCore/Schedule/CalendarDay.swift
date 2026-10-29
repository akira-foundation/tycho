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
        let dayEvents = events.filter { onDay($0.date) }.sorted(by: eventPrecedes)
        let dayTasks = tasks.filter { onDay($0.due) }.sorted(by: taskPrecedes)
        return dayEvents.map(CalendarItem.event) + dayTasks.map(CalendarItem.task)
    }

    public static func chips(for items: [CalendarItem]) -> CalendarChips {
        CalendarChips(shown: Array(items.prefix(chipLimit)), overflow: max(0, items.count - chipLimit))
    }

    private static func eventPrecedes(_ lhs: CalendarEvent, _ rhs: CalendarEvent) -> Bool {
        (lhs.time, lhs.title, lhs.id.uuidString) < (rhs.time, rhs.title, rhs.id.uuidString)
    }

    private static func taskPrecedes(_ lhs: TaskItem, _ rhs: TaskItem) -> Bool {
        let left = (lhs.project?.sortOrder ?? 0, lhs.sortOrder, lhs.title, lhs.id.uuidString)
        let right = (rhs.project?.sortOrder ?? 0, rhs.sortOrder, rhs.title, rhs.id.uuidString)
        return left < right
    }
}
