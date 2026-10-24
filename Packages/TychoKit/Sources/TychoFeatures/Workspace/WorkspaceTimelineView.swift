import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct WorkspaceTimelineView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query private var milestones: [Milestone]

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Timeline", subtitle: "Schedules, dependencies, and milestones across projects.") {}
            Divider()
            TimelineView(
                tasks: tasks.inLiveProjects(),
                milestones: milestones.inLiveProjects(),
                project: nil)
        }
        .navigationTitle("Timeline")
        .onAppear { router.openWorkspaceTimeline() }
    }
}
