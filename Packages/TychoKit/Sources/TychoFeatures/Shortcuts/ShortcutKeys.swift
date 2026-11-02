import SwiftUI
import TychoDesign

enum ShortcutToken: Hashable {
    case key(String)
    case then
}

enum ShortcutKeys {
    static func tokens(_ keys: [String]) -> [ShortcutToken] {
        let isSequence = keys.first == "G"
        return keys.enumerated().flatMap { index, key -> [ShortcutToken] in
            index > 0 && isSequence ? [.then, .key(key)] : [.key(key)]
        }
    }
}

struct ShortcutKeyChip: View {
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

struct ShortcutKeysView: View {
    let keys: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(ShortcutKeys.tokens(keys).enumerated()), id: \.offset) { _, token in
                switch token {
                case .key(let key): ShortcutKeyChip(key)
                case .then: Text("then").tychoFont(.xxs).foregroundStyle(Token.text3.color)
                }
            }
        }
    }
}

struct ShortcutGroupView: View {
    let title: String
    let entries: [ShortcutCatalog.Entry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .tychoFont(.xxs, weight: .semibold)
                .tracking(0.6)
                .foregroundStyle(Token.text3.color)
                .padding(.bottom, 6)
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                HStack(spacing: 4) {
                    Text(entry.label)
                        .tychoFont(.sm)
                        .foregroundStyle(Token.text.color)
                    Spacer(minLength: 8)
                    ShortcutKeysView(keys: entry.keys)
                }
                .frame(height: 30)
                .overlay(alignment: .bottom) { Divider() }
            }
        }
    }
}
