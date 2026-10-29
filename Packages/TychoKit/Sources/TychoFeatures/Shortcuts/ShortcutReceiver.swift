import SwiftUI

#if os(macOS)
import AppKit
#endif

struct ShortcutReceiver: ViewModifier {
    @Environment(Router.self) private var router
    @State private var chord = KeyChord()

    func body(content: Content) -> some View {
        #if os(macOS)
        content.modifier(
            WindowKeyMonitor { event, window in
                guard let key = event.characters?.first else { return false }
                return receive(key, isInField: window.firstResponder is NSText)
            })
        #else
        content.onKeyPress(phases: .down) { press in
            guard press.modifiers.isDisjoint(with: [.command, .control, .option]),
                let key = press.characters.first
            else { return .ignored }
            return receive(key, isInField: false) ? .handled : .ignored
        }
        #endif
    }

    private func receive(_ key: Character, isInField: Bool) -> Bool {
        let now = Date.now
        let isEditing = router.isEditingText || isInField
        let hasSheet = router.hasModalPresentation
        let wasArmed = chord.isArmed(at: now)
        let action = chord.handle(key, at: now, isEditingText: isEditing, hasSheet: hasSheet)
        if let action { router.perform(action) }
        guard !isEditing, !hasSheet else { return false }
        return action != nil || wasArmed || chord.isArmed(at: now)
    }
}

struct TextEditingMarker: ViewModifier {
    @Environment(Router.self) private var router: Router?
    @FocusState private var isFocused: Bool
    @State private var field = UUID()

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onChange(of: isFocused) { router?.markEditing(field, isFocused) }
            .onDisappear { router?.markEditing(field, false) }
    }
}

extension View {
    func shortcutReceiver() -> some View {
        modifier(ShortcutReceiver())
    }

    func marksTextEditing() -> some View {
        modifier(TextEditingMarker())
    }
}
