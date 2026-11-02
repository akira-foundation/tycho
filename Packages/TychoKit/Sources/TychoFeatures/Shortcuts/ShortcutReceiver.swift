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
                guard event.modifierFlags.isDisjoint(with: [.command, .control]),
                    let key = event.characters?.first
                else { return false }
                return receive(
                    key, hasOption: event.modifierFlags.contains(.option),
                    isInField: window.firstResponder is NSText)
            })
        #else
        content.onKeyPress(phases: .down) { press in
            guard press.modifiers.isDisjoint(with: [.command, .control]),
                let key = press.characters.first
            else { return .ignored }
            return receive(key, hasOption: press.modifiers.contains(.option), isInField: false) ? .handled : .ignored
        }
        #endif
    }

    private func receive(_ key: Character, hasOption: Bool, isInField: Bool) -> Bool {
        let result = chord.receive(
            key, hasOption: hasOption, at: .now, isEditingText: router.isEditingText || isInField,
            hasSheet: router.hasModalPresentation)
        if let action = result.action { router.perform(action) }
        return result.consumes
    }
}

extension View {
    func shortcutReceiver() -> some View {
        modifier(ShortcutReceiver())
    }
}
