import SwiftData
import SwiftUI
import TychoCore

struct WorkspaceCalendarView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query(sort: \CalendarEvent.time) private var events: [CalendarEvent]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @Environment(\.isCompactWidth) private var isCompactWidth
    @State private var model = TaskViewModel(key: TaskViewStates.calendarKey, inProject: false)

    var body: some View {
        CalendarView(
            tasks: model.apply(tasks.inLiveProjects(), now: .now, calendar: DateText.gregorian),
            events: events.inLiveProjects()
        )
        .taskViewControls(TaskViewEngine(model: model, members: members, projects: projects)) {
            if isCompactWidth { CalendarModePicker().pickerStyle(.menu) }
        }
        .tracksLiveProjects(model)
        .toolbar {
            if !isCompactWidth {
                ToolbarItem { CalendarModePicker().pickerStyle(.segmented) }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New Task", systemImage: "plus") { router.newTask() }
            }
        }
        .navigationTitle("Calendar")
        .navigationSubtitle("Deadlines and events across every project.")
    }
}
