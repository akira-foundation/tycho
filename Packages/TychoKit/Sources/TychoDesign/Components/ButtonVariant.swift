import CoreGraphics

public enum ButtonVariant: CaseIterable, Sendable {
    case primary, secondary, ghost, danger, dangerGhost

    public var hasBorder: Bool { self == .secondary }

    public func foreground(isDark: Bool) -> RGBA {
        let token: Token? =
            switch self {
            case .primary: nil
            case .secondary: .text
            case .ghost: .text2
            case .danger: nil
            case .dangerGhost: .red
            }
        guard let token else { return RGBA(hex: 0xFFFFFF) }
        return isDark ? token.dark : token.light
    }
}

public enum ButtonSize: Sendable {
    case sm, md, lg

    public var height: CGFloat {
        switch self {
        case .sm: 26
        case .md: 30
        case .lg: 36
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .sm: 8
        case .md: 11
        case .lg: 14
        }
    }

    var scale: TypeScale {
        switch self {
        case .sm: .xs
        case .md: .sm
        case .lg: .base
        }
    }
}
