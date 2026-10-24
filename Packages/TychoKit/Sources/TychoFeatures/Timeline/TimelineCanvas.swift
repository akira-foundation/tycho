import SwiftUI
import TychoCore
import TychoDesign

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
        ZStack(alignment: .topLeading) {
            TimelineBackdrop(rows: rows, layout: layout)
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
        .frame(
            width: layout.width, height: Double(rows.count) * TimelineLayout.rowHeight + 40, alignment: .topLeading
        )
        .coordinateSpace(.named(Self.coordinateSpace))
    }

    private func tint(for task: TaskItem) -> Color {
        switch TimelineBarTint.source(for: grouping) {
        case .project: task.project?.color.tint ?? Token.gray.color
        case .status: task.status.tint
        }
    }
}

struct TimelineBackdrop: View {
    let rows: [TimelineRow]
    let layout: TimelineLayout

    var body: some View {
        Canvas { context, size in
            for x in layout.weekendXs {
                context.fill(
                    Path(CGRect(x: x, y: 0, width: layout.dayWidth, height: size.height)),
                    with: .color(Token.surface2.color))
            }
            for (index, row) in rows.enumerated() where row.isHeader {
                let rect = CGRect(
                    x: 0, y: Double(index) * TimelineLayout.rowHeight, width: size.width,
                    height: TimelineLayout.rowHeight)
                context.fill(Path(rect), with: .color(Token.sunken.color))
            }
            for x in layout.weekLineXs {
                context.stroke(vertical(at: x, height: size.height), with: .color(Token.divider.color), lineWidth: 1)
            }
            context.stroke(
                vertical(at: layout.todayLineX, height: size.height), with: .color(.accentColor), lineWidth: 1.5)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func vertical(at x: Double, height: Double) -> Path {
        Path { path in
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
        }
    }
}
