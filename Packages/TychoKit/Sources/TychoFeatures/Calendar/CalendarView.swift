import SwiftUI
import TychoCore
import TychoDesign

struct CalendarView: View {
    @Environment(Router.self) private var router
    let tasks: [TaskItem]
    let events: [CalendarEvent]
    let project: Project?

    var body: some View {
        VStack(spacing: 0) {
            CalendarToolbar(tasks: tasks, showsLegend: project == nil)
            Divider()
            switch router.calendarMode {
            case .month: CalendarMonthGrid(tasks: tasks, events: events)
            case .week: CalendarWeekView(tasks: tasks, events: events)
            }
        }
        .background(Token.bg.color)
    }
}
