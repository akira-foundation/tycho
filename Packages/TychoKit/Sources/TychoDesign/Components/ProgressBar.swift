import SwiftUI

public struct ProgressBar: View {
    private let percent: Int
    private let color: Color

    public init(percent: Int, color: Color) {
        self.percent = percent
        self.color = color
    }

    public var body: some View {
        Gauge(value: ProgressRing.fraction(percent)) { EmptyView() }
            .gaugeStyle(.linearCapacity)
            .labelsHidden()
            .tint(color)
            .accessibilityLabel("\(percent)%")
    }
}
