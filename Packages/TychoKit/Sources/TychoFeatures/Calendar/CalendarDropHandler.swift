import Foundation
import SwiftData
import TychoCore

@MainActor
struct CalendarDropHandler {
    let context: ModelContext

    func drop(_ ids: [UUID], on day: Date, in tasks: [TaskItem], calendar: Calendar) throws -> TaskItem? {
        guard let id = ids.first, let task = tasks.first(where: { $0.id == id }) else { return nil }
        return try TaskActions(context: context).reschedule(task, toDue: day, calendar: calendar) ? task : nil
    }

    func announceDrop(
        _ ids: [UUID], on day: Date, in tasks: [TaskItem], toast: ToastCenter, dateText: DateText
    )
        -> Bool
    {
        var moved: TaskItem?
        toast.perform { moved = try drop(ids, on: day, in: tasks, calendar: dateText.calendar) }
        guard let moved else { return false }
        toast.show(ScheduleMessages.rescheduled(moved.title, to: day, dateText: dateText))
        return true
    }
}
