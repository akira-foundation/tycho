import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct WorkspaceCalendarView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query(sort: \CalendarEvent.time) private var events: [CalendarEvent]

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Calendar", subtitle: "Deadlines and events across every project.") {
                Button("New task", systemImage: "plus") { router.newTask() }
                    .buttonStyle(.borderedProminent)
            }
            Divider()
            CalendarView(
                tasks: tasks.inLiveProjects(),
                events: events.inLiveProjects(),
                project: nil)
        }
        .navigationTitle("Calendar")
    }
}
