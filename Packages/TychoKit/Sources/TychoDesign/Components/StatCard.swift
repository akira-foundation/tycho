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
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: symbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(tone.map(AnyShapeStyle.init) ?? AnyShapeStyle(.primary))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(tone.map(AnyShapeStyle.init) ?? AnyShapeStyle(.secondary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
