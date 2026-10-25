import SwiftUI

public enum StatusGlyph: Equatable, Sendable {
    case dashed
    case partial(Double)
    case done
}

public struct StatusIcon: View {
    private let glyph: StatusGlyph
    private let color: Color
    private let size: CGFloat

    public init(glyph: StatusGlyph, color: Color, size: CGFloat = 14) {
        self.glyph = glyph
        self.color = color
        self.size = size
    }

    public var body: some View {
        ZStack {
            switch glyph {
            case .dashed:
                Circle().strokeBorder(color, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
            case .partial(let fraction):
                Circle().strokeBorder(color, lineWidth: 1.5)
                Pie(fraction: fraction)
                    .fill(color)
                    .padding(size * 0.22)
            case .done:
                Circle().fill(color)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.55, weight: .bold))
                    .foregroundStyle(Token.textInv.color)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct Pie: Shape {
    let fraction: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: min(rect.width, rect.height) / 2,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * min(max(fraction, 0), 1)),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
