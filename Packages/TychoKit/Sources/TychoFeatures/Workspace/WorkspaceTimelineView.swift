import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct WorkspaceTimelineView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query private var milestones: [Milestone]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model = TaskViewModel(key: TaskViewStates.timelineKey, inProject: false)

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Timeline", subtitle: "Schedules, dependencies, and milestones across projects.") {}
            Divider()
            TimelineView(
                tasks: model.apply(tasks.inLiveProjects(), now: .now, calendar: DateText.gregorian),
                milestones: milestones.inLiveProjects(),
                project: nil,
                engine: TaskViewEngine(model: model, members: members, projects: projects))
        }
        .tracksLiveProjects(model)
        .navigationTitle("Timeline")
        .onAppear { router.openWorkspaceTimeline() }
    }
}
