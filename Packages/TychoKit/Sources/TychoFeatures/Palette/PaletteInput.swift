import SwiftUI
import TychoCore
import TychoDesign

struct PaletteInput: View {
    @Binding var state: PaletteState
    let itemCount: Int
    let onRun: () -> Void
    let onClose: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: state.mode == .search ? "magnifyingglass" : "command")
                .font(.system(size: 15))
                .foregroundStyle(Token.text3.color)
            if state.mode == .search {
                Text("Search")
                    .tychoFont(.xxs, weight: .medium)
                    .foregroundStyle(Token.text2.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Token.surface2.color, in: Capsule())
                    .fixedSize()
            }
            TextField(placeholder, text: $state.query)
                .marksTextEditing(isFocused: isFocused)
                .textFieldStyle(.plain)
                .tychoFont(.md)
                .autocorrectionDisabled()
                .focused($isFocused)
                .accessibilityIdentifier("palette.input")
                .onKeyPress(keys: [.upArrow, .downArrow, .return, .tab, .escape, .delete], phases: .down) {
                    handle($0.key)
                }
                .onSubmit { onRun() }
                .onChange(of: state.query) { state.highlight = 0 }
            ShortcutKeyChip("Esc")
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .paletteKeyMonitor { handle($0) }
        .focusedOnTheNextRunLoopTurn($isFocused)
    }

    private var placeholder: String {
        switch state.mode {
        case .commands: "Type a command or search…"
        case .search: "Search tasks, projects, files…"
        }
    }

    private func handle(_ key: KeyEquivalent) -> KeyPress.Result {
        switch PaletteKeys.apply(key, to: &state, itemCount: itemCount) {
        case .ignored: return .ignored
        case .handled: break
        case .run: onRun()
        case .close: onClose()
        }
        return .handled
    }
}

enum PaletteKeyOutcome: Equatable {
    case ignored
    case handled
    case run
    case close
}

enum PaletteKeys {
    static func apply(_ key: KeyEquivalent, to state: inout PaletteState, itemCount: Int) -> PaletteKeyOutcome {
        switch key {
        case .upArrow:
            state.highlight = PaletteSections.moved(state.highlight, by: -1, count: itemCount)
        case .downArrow:
            state.highlight = PaletteSections.moved(state.highlight, by: 1, count: itemCount)
        case .return:
            return .run
        case .tab:
            state.mode = state.mode == .commands ? .search : .commands
            state.highlight = 0
        case .escape:
            return .close
        case .delete:
            guard state.query.isEmpty, state.mode != .commands else { return .ignored }
            state.mode = .commands
            state.highlight = 0
        default:
            return .ignored
        }
        return .handled
    }
}
