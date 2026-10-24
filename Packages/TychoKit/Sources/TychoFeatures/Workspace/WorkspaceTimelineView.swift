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
                tasks: tasks.filter { $0.project?.isArchived == false },
                milestones: milestones.filter { $0.project?.isArchived == false },
                project: nil)
        }
        .navigationTitle("Timeline")
        .onAppear { router.openWorkspaceTimeline() }
    }
}
