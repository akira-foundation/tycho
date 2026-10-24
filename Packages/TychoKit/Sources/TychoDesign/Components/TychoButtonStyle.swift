import SwiftUI

public struct TychoButtonStyle: ButtonStyle {
    private let variant: ButtonVariant
    private let size: ButtonSize
    private let block: Bool

    public init(_ variant: ButtonVariant, size: ButtonSize = .md, block: Bool = false) {
        self.variant = variant
        self.size = size
        self.block = block
    }

    public func makeBody(configuration: Configuration) -> some View {
        StyledLabel(configuration: configuration, variant: variant, size: size, block: block)
    }

    private struct StyledLabel: View {
        let configuration: ButtonStyleConfiguration
        let variant: ButtonVariant
        let size: ButtonSize
        let block: Bool

        @Environment(\.colorScheme) private var scheme
        @Environment(\.isEnabled) private var isEnabled
        @State private var hovering = false

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
            configuration.label
                .tychoFont(size.scale, weight: .medium)
                .foregroundStyle(foreground)
                .padding(.horizontal, size.horizontalPadding)
                .frame(maxWidth: block ? .infinity : nil)
                .frame(height: size.height)
                .background(fill, in: shape)
                .overlay { if variant.hasBorder { shape.strokeBorder(Token.borderStrong.color, lineWidth: 1) } }
                .overlay(alignment: .bottom) { if variant == .primary && isEnabled { insetEdge(shape) } }
                .contentShape(shape)
                .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1)
                .opacity(isEnabled ? 1 : 0.45)
                .onHover { hovering = $0 }
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }

        private var foreground: Color {
            let value = variant.foreground(isDark: scheme == .dark)
            let color = Color(.sRGB, red: value.red, green: value.green, blue: value.blue, opacity: value.alpha)
            guard variant == .ghost, hovering || configuration.isPressed else { return color }
            return Token.text.color
        }

        private var fill: Color {
            let pressed = configuration.isPressed
            switch variant {
            case .primary:
                return Color.accentColor.mix(with: Token.text.color, by: pressed ? 0.22 : hovering ? 0.12 : 0)
            case .secondary:
                return pressed ? Token.surface3.color : hovering ? Token.surface2.color : Token.surface.color
            case .ghost:
                return pressed ? Token.surface3.color : hovering ? Token.surface2.color : .clear
            case .danger:
                return Token.red.color.mix(with: .black, by: hovering || pressed ? 0.12 : 0)
            case .dangerGhost:
                return hovering || pressed ? Token.red.soft(0.10) : .clear
            }
        }

        private func insetEdge(_ shape: RoundedRectangle) -> some View {
            Rectangle().fill(Color.black.opacity(0.12)).frame(height: 1)
                .clipShape(shape)
        }
    }
}

extension ButtonStyle where Self == TychoButtonStyle {
    public static func tycho(_ variant: ButtonVariant, size: ButtonSize = .md, block: Bool = false) -> Self {
        TychoButtonStyle(variant, size: size, block: block)
    }
}
