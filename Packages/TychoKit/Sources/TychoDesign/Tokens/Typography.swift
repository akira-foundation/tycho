import SwiftUI

public enum TypeScale: CaseIterable, Sendable {
    case xxs, xs, sm, base, md, lg, xl, xxl

    public var points: CGFloat {
        switch self {
        case .xxs: 11
        case .xs: 12
        case .sm: 12.5
        case .base: 13.5
        case .md: 14.5
        case .lg: 16
        case .xl: 19
        case .xxl: 23
        }
    }

    public var textStyle: Font.TextStyle {
        switch self {
        case .xxs: .caption2
        case .xs: .caption
        case .sm: .footnote
        case .base: .subheadline
        case .md: .callout
        case .lg: .body
        case .xl: .title3
        case .xxl: .title2
        }
    }
}

struct TychoFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(scale: TypeScale, weight: Font.Weight, design: Font.Design) {
        _size = ScaledMetric(wrappedValue: scale.points, relativeTo: scale.textStyle)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    public func tychoFont(
        _ scale: TypeScale, weight: Font.Weight = .regular, design: Font.Design = .default
    ) -> some View {
        modifier(TychoFont(scale: scale, weight: weight, design: design))
    }
}
