import SwiftData
import SwiftUI
import TychoCore

struct WorkspaceTimelineView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query private var milestones: [Milestone]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @Environment(\.isCompactWidth) private var isCompactWidth
    @State private var model = TaskViewModel(key: TaskViewStates.timelineKey, inProject: false)

    var body: some View {
        TimelineView(
            tasks: model.apply(tasks.inLiveProjects(), now: .now, calendar: DateText.gregorian),
            milestones: milestones.inLiveProjects(),
            project: nil
        )
        .taskViewControls(TaskViewEngine(model: model, members: members, projects: projects)) {
            TimelineOptions(showsZoom: isCompactWidth)
        }
        .toolbar {
            if !isCompactWidth {
                ToolbarItem { TimelineZoomPicker().pickerStyle(.segmented) }
                ToolbarItem { TimelineTodayButton() }
            }
        }
        .tracksLiveProjects(model)
        .navigationTitle("Timeline")
        .navigationSubtitle("Schedules, dependencies, and milestones across projects.")
        .onAppear { router.openWorkspaceTimeline() }
    }
}
