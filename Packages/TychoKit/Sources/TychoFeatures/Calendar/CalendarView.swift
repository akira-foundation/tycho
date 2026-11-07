import SwiftUI
import TychoCore

struct CalendarView: View {
    @Environment(Router.self) private var router
    let tasks: [TaskItem]
    let events: [CalendarEvent]

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeader()
            switch router.calendarMode {
            case .month: CalendarMonthGrid(tasks: tasks, events: events)
            case .week: CalendarWeekView(tasks: tasks, events: events)
            }
        }
    }
}
