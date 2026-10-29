import SwiftUI
import TychoCore
import TychoDesign

struct PalettePanel: View {
    @Binding var state: PaletteState
    let sections: [PaletteSection]
    let onRun: (PaletteItem) -> Void
    let onClose: () -> Void
    @State private var listHeight: CGFloat = 0

    private var items: [PaletteItem] { PaletteSections.flattened(sections) }

    var body: some View {
        VStack(spacing: 0) {
            PaletteInput(state: $state, itemCount: items.count, onRun: runHighlighted, onClose: onClose)
            Divider().overlay(Token.border.color)
            if state.mode == .search {
                scopes
                Divider().overlay(Token.divider.color)
            }
            list
            Divider().overlay(Token.border.color)
            footer
        }
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadowPop(radius: 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Command menu")
        .accessibilityAddTraits(.isModal)
    }

    private var scopes: some View {
        HStack(spacing: 4) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Button {
                    state.scope = scope
                    state.highlight = 0
                } label: {
                    Label(scope.title, systemImage: symbol(for: scope))
                        .labelStyle(.titleAndIcon)
                        .tychoFont(.xs)
                        .padding(.horizontal, 9)
                        .frame(height: 24)
                        .foregroundStyle(state.scope == scope ? Token.textInv.color : Token.text2.color)
                        .background(state.scope == scope ? Token.text.color : Color.clear, in: Capsule())
                        .overlay(Capsule().strokeBorder(state.scope == scope ? Token.text.color : Token.border.color))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("palette.scope.\(scope.rawValue)")
                .accessibilityAddTraits(state.scope == scope ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func symbol(for scope: SearchScope) -> String {
        switch scope {
        case .all: "square.3.layers.3d"
        case .tasks: "checkmark.circle"
        case .projects: "folder"
        case .files: "paperclip"
        }
    }

    @ViewBuilder private var list: some View {
        if items.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "text.magnifyingglass").font(.system(size: 18)).foregroundStyle(Token.text3.color)
                Text("No results found").tychoFont(.md, weight: .semibold).foregroundStyle(Token.text.color)
                Text("Try a different keyword, or press Tab to search everything.")
                    .tychoFont(.sm)
                    .foregroundStyle(Token.text3.color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    rows
                        .padding(6)
                        .onGeometryChange(for: CGFloat.self) {
                            $0.size.height
                        } action: {
                            listHeight = $0
                        }
                }
                .frame(maxHeight: listHeight > 0 ? listHeight : nil)
                .onChange(of: state.highlight) {
                    guard items.indices.contains(state.highlight) else { return }
                    proxy.scrollTo(items[state.highlight].id)
                }
            }
        }
    }

    private var rows: some View {
        let offsets = sectionOffsets
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                if index > 0 {
                    Divider().overlay(Token.divider.color).padding(.vertical, 2)
                }
                if !section.title.isEmpty {
                    Text(section.title.uppercased())
                        .tychoFont(.xxs, weight: .semibold)
                        .tracking(0.6)
                        .foregroundStyle(Token.text3.color)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                }
                ForEach(Array(section.items.enumerated()), id: \.element.id) { position, item in
                    row(item, index: offsets[index] + position)
                }
            }
        }
    }

    private func row(_ item: PaletteItem, index: Int) -> some View {
        Button {
            onRun(item)
        } label: {
            PaletteRow(item: item, query: state.query, isHighlighted: index == state.highlight)
        }
        .buttonStyle(.plain)
        .id(item.id)
        .accessibilityIdentifier("palette.item.\(item.id)")
        .accessibilityAddTraits(index == state.highlight ? .isSelected : [])
        .onHover { hovering in
            if hovering { state.highlight = index }
        }
    }

    private var sectionOffsets: [Int] {
        var running = 0
        return sections.map { section in
            defer { running += section.items.count }
            return running
        }
    }

    private var footer: some View {
        HStack(spacing: 14) {
            hint(keys: ["↑", "↓"], label: "navigate")
            hint(keys: ["↵"], label: "select")
            switch state.mode {
            case .commands: hint(keys: ["Tab"], label: "search mode")
            case .search: hint(keys: ["⌫"], label: "back to commands")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Token.sunken.color)
    }

    private func hint(keys: [String], label: String) -> some View {
        HStack(spacing: 5) {
            ForEach(keys, id: \.self) { ShortcutKeyChip($0) }
            Text(label).tychoFont(.xs).foregroundStyle(Token.text3.color)
        }
    }

    private func runHighlighted() {
        guard items.indices.contains(state.highlight) else { return }
        onRun(items[state.highlight])
    }
}
