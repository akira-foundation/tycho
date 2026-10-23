import SwiftUI

public struct StatCard: View {
    private let title: String
    private let symbol: String
    private let value: String
    private let detail: String
    private let tone: Color?
    private let action: () -> Void

    public init(
        title: String, symbol: String, value: String, detail: String, tone: Color?,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.value = value
        self.detail = detail
        self.tone = tone
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.s2) {
                Label(title, systemImage: symbol)
                    .tychoFont(.xs, weight: .medium)
                    .foregroundStyle(Token.text3.color)
                Text(value)
                    .tychoFont(.xxl, weight: .semibold)
                    .monospacedDigit()
                    .foregroundStyle(tone ?? Token.text.color)
                Text(detail)
                    .tychoFont(.xs)
                    .foregroundStyle(tone ?? Token.text3.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.s4)
            .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .shadowCard(radius: Radius.lg)
        }
        .buttonStyle(.plain)
    }
}
