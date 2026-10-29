import SwiftUI
import TychoCore
import TychoDesign

struct PaletteRow: View {
    let item: PaletteItem
    let query: String
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 10) {
            PaletteVisualIcon(visual: item.visual)
                .frame(width: 18)
            Text(PaletteHighlight.title(item.title, query: query))
                .tychoFont(.base)
                .foregroundStyle(Token.text.color)
                .lineLimit(1)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .tychoFont(.xs)
                    .foregroundStyle(Token.text3.color)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            trailing
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(
            isHighlighted ? Token.surface2.color : Color.clear,
            in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder private var trailing: some View {
        if let text = item.trailing {
            switch item.kind {
            case .command:
                HStack(spacing: 4) {
                    ForEach(Array(text.split(separator: " ").enumerated()), id: \.offset) { _, key in
                        PaletteKeyChip(String(key))
                    }
                }
            default:
                Text(text)
                    .tychoFont(.xs, design: .monospaced)
                    .foregroundStyle(Token.text3.color)
            }
        }
    }
}

struct PaletteVisualIcon: View {
    let visual: PaletteVisual?

    var body: some View {
        switch visual {
        case .status(let status):
            StatusIcon(glyph: status.glyph, color: status.tint)
        case .project(let symbol, let color):
            ProjectGlyph(symbol: symbol, color: color.tint, size: 18)
        case .file(let kind):
            Image(systemName: kind.symbol).foregroundStyle(kind.tint)
        case .symbol(let name):
            Image(systemName: name).foregroundStyle(Token.text2.color)
        case nil:
            Image(systemName: "circle").foregroundStyle(Token.text2.color)
        }
    }
}

struct PaletteKeyChip: View {
    private let key: String

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(key)
            .tychoFont(.xxs, weight: .medium)
            .foregroundStyle(Token.text3.color)
            .padding(.horizontal, 5)
            .frame(minWidth: 18, minHeight: 18)
            .background(Token.surface2.color, in: RoundedRectangle(cornerRadius: Radius.xs, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                    .strokeBorder(Token.border.color, lineWidth: 1))
    }
}

enum PaletteHighlight {
    static func title(_ title: String, query: String) -> AttributedString {
        var attributed = AttributedString(title)
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty, let range = attributed.range(of: needle, options: .caseInsensitive) else {
            return attributed
        }
        attributed[range].inlinePresentationIntent = .stronglyEmphasized
        attributed[range].foregroundColor = Color.accentColor
        return attributed
    }
}
