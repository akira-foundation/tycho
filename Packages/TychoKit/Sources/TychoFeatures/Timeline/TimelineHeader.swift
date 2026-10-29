import SwiftUI
import TychoCore
import TychoDesign

struct TimelineHeader: View {
    static let height: CGFloat = 48
    let layout: TimelineLayout

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(layout.monthBlocks) { block in
                    Text(block.title)
                        .tychoFont(.xs, weight: .semibold)
                        .lineLimit(1)
                        .padding(.leading, 6)
                        .frame(width: block.width, height: Self.height / 2, alignment: .leading)
                }
            }
            HStack(spacing: 0) {
                ForEach(layout.headerCells) { cell in
                    Text(cell.title)
                        .tychoFont(.xxs, weight: cell.isToday ? .semibold : .regular)
                        .monospacedDigit()
                        .lineLimit(1)
                        .foregroundStyle(cell.isToday ? Color.accentColor : Token.text3.color)
                        .frame(width: cell.width, height: Self.height / 2)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("timeline.header.\(layout.zoom.rawValue)")
        }
        .frame(width: layout.width, alignment: .leading)
    }
}
