import SwiftUI

public struct ProgressRing: View {
    private let percent: Int
    private let color: Color
    private let size: CGFloat

    public init(percent: Int, color: Color, size: CGFloat = 16) {
        self.percent = percent
        self.color = color
        self.size = size
    }

    public static func fraction(_ percent: Int) -> Double { Double(min(max(percent, 0), 100)) / 100 }

    public var body: some View {
        ZStack {
            Circle().stroke(Token.border.color, lineWidth: 2)
            Circle()
                .trim(from: 0, to: Self.fraction(percent))
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(percent)%")
    }
}
