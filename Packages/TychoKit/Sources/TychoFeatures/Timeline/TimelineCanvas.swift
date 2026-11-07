import SwiftUI
import TychoCore

enum TimelineBarTint: Equatable {
    case project
    case status

    static func source(for grouping: TimelineGrouping) -> TimelineBarTint {
        switch grouping {
        case .status, .none: .project
        case .assignee, .project: .status
        }
    }
}

struct TimelineCanvas: View {
    static let coordinateSpace = "timeline.canvas"
    let rows: [TimelineRow]
    let layout: TimelineLayout
    let grouping: TimelineGrouping
    let pins: [MilestonePin]
    let curves: [DependencyCurve]

    var body: some View {
        let height = Double(rows.count) * TimelineLayout.rowHeight + 40
        ZStack(alignment: .topLeading) {
            TimelineBackdrop(rows: rows, layout: layout)
                .frame(width: layout.width, height: height)
            TimelineMilestones(pins: pins)
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                if case .task(let task) = row, let due = task.due {
                    TimelineBar(
                        task: task, frame: layout.barFrame(start: task.start, due: due),
                        start: layout.barStart(start: task.start, due: due), tint: tint(for: task), layout: layout
                    )
                    .offset(y: Double(index) * TimelineLayout.rowHeight + 7)
                }
            }
            TimelineDependencies(curves: curves)
        }
        .frame(width: layout.width, height: height, alignment: .topLeading)
        .coordinateSpace(.named(Self.coordinateSpace))
    }

    private func tint(for task: TaskItem) -> Color {
        switch TimelineBarTint.source(for: grouping) {
        case .project: task.project?.color.tint ?? .gray
        case .status: task.status.tint
        }
    }
}

struct TimelineBackdrop: View {
    let rows: [TimelineRow]
    let layout: TimelineLayout

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(layout.weekendXs, id: \.self) { x in
                Rectangle().fill(Color.primary.opacity(0.04)).frame(width: layout.dayWidth).offset(x: x)
            }
            ForEach(headerIndices, id: \.self) { index in
                Rectangle()
                    .fill(Color.primary.opacity(0.05))
                    .frame(height: TimelineLayout.rowHeight)
                    .offset(y: Double(index) * TimelineLayout.rowHeight)
            }
            ForEach(layout.weekLineXs, id: \.self) { x in
                Rectangle().fill(.separator).frame(width: 0.5).offset(x: x)
            }
            Rectangle().fill(Color.accentColor).frame(width: 1.5).offset(x: layout.todayLineX)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var headerIndices: [Int] {
        rows.indices.filter { rows[$0].isHeader }
    }
}
