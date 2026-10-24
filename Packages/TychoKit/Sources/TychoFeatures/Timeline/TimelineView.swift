import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TimelineView: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @Query(sort: \Member.name) private var members: [Member]
    let tasks: [TaskItem]
    let milestones: [Milestone]
    let project: Project?
    @State private var horizontal = ScrollPosition(edge: .leading)
    @State private var vertical = ScrollPosition(edge: .top)

    var body: some View {
        let layout = makeLayout()
        let grouping = router.timelineGrouping.effective(inProject: project != nil)
        let rows = TimelineRows.build(
            tasks: tasks, grouping: grouping, milestoneCount: milestones.count, members: members, projects: projects)
        VStack(spacing: 0) {
            TimelineControls(showsNewTask: project != nil) { horizontal.scrollTo(x: layout.initialScrollX) }
            Divider()
            if rows.isEmpty {
                empty
            } else {
                panes(rows: rows, layout: layout, grouping: grouping)
            }
        }
        .background(Token.bg.color)
        .onAppear { horizontal.scrollTo(x: layout.initialScrollX) }
        .onChange(of: router.timelineZoom) { horizontal.scrollTo(x: makeLayout().initialScrollX) }
    }

    private func makeLayout() -> TimelineLayout {
        TimelineLayout(zoom: router.timelineZoom, today: .now, weekStart: weekStart, calendar: DateText.gregorian)
    }

    private func panes(rows: [TimelineRow], layout: TimelineLayout, grouping: TimelineGrouping) -> some View {
        HStack(alignment: .top, spacing: 0) {
            TimelineTaskPane(rows: rows, position: $vertical)
                .frame(width: 280)
            Divider()
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 0) {
                    TimelineHeader(layout: layout)
                    Divider()
                    ScrollView(.vertical) {
                        TimelineCanvas(rows: rows, layout: layout, grouping: grouping)
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.y
                    } action: { _, offset in
                        vertical.scrollTo(y: offset)
                    }
                }
            }
            .scrollPosition($horizontal)
        }
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
