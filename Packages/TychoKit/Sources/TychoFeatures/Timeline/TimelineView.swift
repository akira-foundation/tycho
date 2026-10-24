import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TimelineView: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    @Environment(\.dateText) private var dateText
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @Query(sort: \Member.name) private var members: [Member]
    let tasks: [TaskItem]
    let milestones: [Milestone]
    let project: Project?
    @State private var sync = TimelineScrollSync()

    var body: some View {
        let layout = makeLayout()
        let grouping = router.timelineGrouping.effective(inProject: project != nil)
        let rows = TimelineRows.build(
            tasks: tasks, grouping: grouping, milestoneCount: milestones.count, members: members, projects: projects)
        VStack(spacing: 0) {
            TimelineControls(showsNewTask: project != nil) { sync.scrollHorizontally(to: layout.initialScrollX) }
            Divider()
            if rows.isEmpty {
                empty
            } else {
                TimelinePanes(
                    rows: rows, layout: layout, grouping: grouping,
                    pins: MilestoneLane.pins(
                        for: MilestoneMark.marks(from: milestones, includeProject: project == nil),
                        layout: layout, dateText: dateText),
                    curves: DependencyPath.curves(rows: rows, layout: layout), sync: sync)
            }
        }
        .background(Token.bg.color)
        .onChange(of: router.timelineZoom) { sync.scrollHorizontally(to: makeLayout().initialScrollX) }
    }

    private func makeLayout() -> TimelineLayout {
        TimelineLayout(zoom: router.timelineZoom, today: .now, weekStart: weekStart, calendar: DateText.gregorian)
    }

    private var empty: some View {
        VStack(spacing: Spacing.s3) {
            EmptyState(
                title: "Nothing on the timeline", symbol: "chart.bar.xaxis",
                message: "Give tasks a start and due date to see them here.")
            Button("New task", systemImage: "plus") { router.newTask() }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
