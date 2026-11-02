import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct WorkspaceCalendarView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query(sort: \CalendarEvent.time) private var events: [CalendarEvent]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model = TaskViewModel(key: TaskViewStates.calendarKey, inProject: false)

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Calendar", subtitle: "Deadlines and events across every project.") {
                Button("New task", systemImage: "plus") { router.newTask() }
                    .buttonStyle(.tycho(.primary))
            }
            Divider()
            CalendarView(
                tasks: model.apply(tasks.inLiveProjects(), now: .now, calendar: DateText.gregorian),
                events: events.inLiveProjects(),
                project: nil,
                engine: TaskViewEngine(model: model, members: members, projects: projects))
        }
        .tracksLiveProjects(model)
        .navigationTitle("Calendar")
    }
}
