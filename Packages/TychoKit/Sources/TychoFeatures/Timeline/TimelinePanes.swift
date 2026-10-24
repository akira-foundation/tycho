import SwiftUI
import TychoCore
import TychoDesign

@Observable
@MainActor
final class TimelineScrollSync {
    var horizontal = ScrollPosition(edge: .leading)
    var vertical = ScrollPosition(edge: .top)

    func scrollHorizontally(to x: Double) { horizontal.scrollTo(x: x) }
}

struct TimelinePanes: View {
    let rows: [TimelineRow]
    let layout: TimelineLayout
    let grouping: TimelineGrouping
    let pins: [MilestonePin]
    let curves: [DependencyCurve]
    let sync: TimelineScrollSync

    var body: some View {
        @Bindable var sync = sync
        HStack(alignment: .top, spacing: 0) {
            TimelineTaskPane(rows: rows, position: $sync.vertical)
                .frame(width: 280)
            Divider()
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 0) {
                    TimelineHeader(layout: layout)
                    Divider()
                    ScrollView(.vertical) {
                        TimelineCanvas(rows: rows, layout: layout, grouping: grouping, pins: pins, curves: curves)
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.y
                    } action: { _, offset in
                        sync.vertical.scrollTo(y: offset)
                    }
                }
            }
            .scrollPosition($sync.horizontal)
        }
        .onAppear { sync.scrollHorizontally(to: layout.initialScrollX) }
    }
}
