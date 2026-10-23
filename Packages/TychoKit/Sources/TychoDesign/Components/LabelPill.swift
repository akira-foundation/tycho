import SwiftUI

public struct LabelPill: View {
    private let title: String
    private let color: Color

    public init(title: String, color: Color) {
        self.title = title
        self.color = color
    }

    public var body: some View {
        HStack(spacing: Spacing.s1) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(title).tychoFont(.xxs, weight: .medium)
        }
        .padding(.horizontal, 6)
        .frame(height: 20)
        .foregroundStyle(Token.text2.color)
        .background(color.opacity(0.12), in: Capsule())
    }
}
