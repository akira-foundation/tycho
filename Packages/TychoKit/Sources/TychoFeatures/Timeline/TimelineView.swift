import SwiftData
import SwiftUI
import TychoCore

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
        let marks = MilestoneMark.marks(from: milestones, includeProject: project == nil)
        let rows = TimelineRows.build(
            tasks: tasks, grouping: grouping, milestoneCount: marks.count, members: members, projects: projects)
        Group {
            if rows.isEmpty {
                empty
            } else {
                TimelinePanes(
                    rows: rows, layout: layout, grouping: router.timelineGrouping,
                    pins: MilestoneLane.pins(for: marks, layout: layout, dateText: dateText),
                    curves: DependencyPath.curves(rows: rows, layout: layout), sync: sync)
            }
        }
        .onChange(of: router.timelineZoom) { scrollToToday() }
        .onChange(of: router.timelineTodayRequests) { scrollToToday() }
    }

    private func scrollToToday() {
        sync.scrollHorizontally(to: makeLayout().initialScrollX)
    }

    private func makeLayout() -> TimelineLayout {
        TimelineLayout(zoom: router.timelineZoom, today: .now, weekStart: weekStart, calendar: DateText.gregorian)
    }

    private var empty: some View {
        ContentUnavailableView {
            Label("Nothing on the Timeline", systemImage: "chart.bar.xaxis")
        } description: {
            Text("Give tasks a start and due date to see them here.")
        } actions: {
            Button("New Task") { router.newTask() }
                .buttonStyle(.borderedProminent)
        }
    }
}
