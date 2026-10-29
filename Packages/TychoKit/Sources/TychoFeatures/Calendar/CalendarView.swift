import SwiftUI
import TychoCore
import TychoDesign

struct CalendarView: View {
    @Environment(Router.self) private var router
    let tasks: [TaskItem]
    let events: [CalendarEvent]
    let project: Project?
    var engine: TaskViewEngine?

    var body: some View {
        VStack(spacing: 0) {
            header
            switch router.calendarMode {
            case .month: CalendarMonthGrid(tasks: tasks, events: events)
            case .week: CalendarWeekView(tasks: tasks, events: events)
            }
        }
        .background(Token.bg.color)
    }

    @ViewBuilder private var header: some View {
        let controls = CalendarToolbar(tasks: tasks, showsLegend: project == nil)
        if let engine {
            TaskViewHeader(engine: engine) { controls }
        } else {
            controls
                .padding(.horizontal, Spacing.s4)
                .padding(.vertical, Spacing.s2)
            Divider()
        }
    }
}
