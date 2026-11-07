import SwiftUI
import TychoCore

struct TimelineHeader: View {
    static let height: CGFloat = 48
    let layout: TimelineLayout

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(layout.monthBlocks) { block in
                    Text(block.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .padding(.leading, 6)
                        .frame(width: block.width, height: Self.height / 2, alignment: .leading)
                }
            }
            HStack(spacing: 0) {
                ForEach(layout.headerCells) { cell in
                    Text(cell.title)
                        .font(.caption2.weight(cell.isToday ? .semibold : .regular))
                        .monospacedDigit()
                        .lineLimit(1)
                        .foregroundStyle(cell.isToday ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.secondary))
                        .frame(width: cell.width, height: Self.height / 2)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("timeline.header.\(layout.zoom.rawValue)")
        }
        .frame(width: layout.width, alignment: .leading)
    }
}
