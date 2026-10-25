import SwiftUI

struct TychoShadow: ViewModifier {
    enum Kind { case card, pop, drag }

    @Environment(\.colorScheme) private var scheme
    let kind: Kind
    let radius: CGFloat

    func body(content: Content) -> some View {
        let dark = scheme == .dark
        let ring =
            kind == .card ? Token.border.color : (dark || kind == .drag ? Token.borderStrong.color : Token.border.color)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return
            content
            .overlay(shape.strokeBorder(ring, lineWidth: 1))
            .shadow(color: shadowColor(dark: dark), radius: blur(dark: dark) / 2, y: offset(dark: dark))
    }

    private func shadowColor(dark: Bool) -> Color {
        let base = dark ? Color.black : Color(hex: 0x1C1914)
        switch kind {
        case .card: return dark ? .clear : base.opacity(0.04)
        case .pop: return base.opacity(dark ? 0.6 : 0.16)
        case .drag: return base.opacity(dark ? 0.7 : 0.28)
        }
    }

    private func blur(dark: Bool) -> CGFloat {
        switch kind {
        case .card: 2
        case .pop: dark ? 40 : 32
        case .drag: dark ? 40 : 36
        }
    }

    private func offset(dark: Bool) -> CGFloat {
        switch kind {
        case .card: 1
        case .pop: dark ? 16 : 12
        case .drag: dark ? 18 : 16
        }
    }
}

extension View {
    public func shadowCard(radius: CGFloat = Radius.md) -> some View {
        modifier(TychoShadow(kind: .card, radius: radius))
    }
    public func shadowPop(radius: CGFloat = Radius.lg) -> some View {
        modifier(TychoShadow(kind: .pop, radius: radius))
    }
    public func shadowDrag(radius: CGFloat = Radius.md) -> some View {
        modifier(TychoShadow(kind: .drag, radius: radius))
    }
}
