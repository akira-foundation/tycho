import CoreGraphics
import SwiftUI
import TychoCore
import TychoDesign

extension TimelinePoint {
    var point: CGPoint { CGPoint(x: x, y: y) }
}

struct TimelineDependencies: View {
    let curves: [DependencyCurve]

    var body: some View {
        Canvas { context, _ in
            for curve in curves {
                var line = Path()
                line.move(to: curve.start.point)
                line.addCurve(to: curve.end.point, control1: curve.control1.point, control2: curve.control2.point)
                context.stroke(
                    line, with: .color(Token.text3.color),
                    style: StrokeStyle(lineWidth: 1.3, dash: curve.isDashed ? [3, 3] : []))
                var arrow = Path()
                arrow.addLines(curve.arrow.map(\.point))
                context.stroke(
                    arrow, with: .color(Token.text3.color),
                    style: StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct TimelineMilestones: View {
    let pins: [MilestonePin]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(pins) { pin in
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(pin.colorHex.map { Color(hex: $0) } ?? Token.text2.color)
                        .frame(width: 9, height: 9)
                        .rotationEffect(.degrees(45))
                    if let label = pin.label {
                        Text(label)
                            .tychoFont(.xs, weight: .medium)
                            .lineLimit(1)
                            .frame(maxWidth: pin.labelWidth.map { CGFloat($0) }, alignment: .leading)
                            .fixedSize(horizontal: pin.labelWidth == nil, vertical: false)
                    }
                }
                .offset(x: pin.x - 6, y: 12)
                .help(pin.tooltip)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Milestone: \(pin.tooltip)")
            }
        }
    }
}
