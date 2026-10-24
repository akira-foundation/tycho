import SwiftUI
import TychoCore
import TychoDesign

struct CalendarView: View {
    let tasks: [TaskItem]
    let events: [CalendarEvent]
    let project: Project?

    var body: some View {
        VStack(spacing: 0) {
            CalendarToolbar(tasks: tasks, showsLegend: project == nil)
            Divider()
            CalendarMonthGrid(tasks: tasks, events: events)
        }
        .background(Token.bg.color)
    }
}
