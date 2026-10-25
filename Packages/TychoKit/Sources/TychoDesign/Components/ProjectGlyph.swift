import SwiftUI

public struct ProjectGlyph: View {
    private let symbol: String
    private let color: Color
    private let size: CGFloat

    public init(symbol: String, color: Color, size: CGFloat = 20) {
        self.symbol = symbol
        self.color = color
        self.size = size
    }

    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.55, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
            .accessibilityHidden(true)
    }
}
