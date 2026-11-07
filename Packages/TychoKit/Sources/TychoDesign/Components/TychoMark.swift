import SwiftUI

public struct TychoMark: View {
    private static let core = Color(red: 232 / 255, green: 150 / 255, blue: 31 / 255)

    private let size: CGFloat

    public init(size: CGFloat = 64) {
        self.size = size
    }

    public var body: some View {
        let unit = size / 100
        ZStack {
            TychoMarkRays()
                .stroke(.primary, style: StrokeStyle(lineWidth: 5 * unit, lineCap: .round))
            Circle()
                .stroke(.primary, lineWidth: 7 * unit)
                .frame(width: 30 * unit, height: 30 * unit)
            Circle()
                .fill(Self.core)
                .frame(width: 10.4 * unit, height: 10.4 * unit)
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel("Tycho")
    }
}

struct TychoMarkRays: Shape {
    static let segments: [(CGPoint, CGPoint)] = [
        (CGPoint(x: 50, y: 27), CGPoint(x: 50, y: 6)),
        (CGPoint(x: 50, y: 73), CGPoint(x: 50, y: 86)),
        (CGPoint(x: 27, y: 50), CGPoint(x: 12, y: 50)),
        (CGPoint(x: 73, y: 50), CGPoint(x: 94, y: 50)),
        (CGPoint(x: 66.3, y: 33.7), CGPoint(x: 76.9, y: 23.1)),
        (CGPoint(x: 33.7, y: 66.3), CGPoint(x: 23.1, y: 76.9)),
        (CGPoint(x: 33.7, y: 33.7), CGPoint(x: 28, y: 28)),
        (CGPoint(x: 66.3, y: 66.3), CGPoint(x: 80.4, y: 80.4)),
    ]

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 100
        var path = Path()
        for (start, end) in Self.segments {
            path.move(to: CGPoint(x: rect.minX + start.x * scale, y: rect.minY + start.y * scale))
            path.addLine(to: CGPoint(x: rect.minX + end.x * scale, y: rect.minY + end.y * scale))
        }
        return path
    }
}
