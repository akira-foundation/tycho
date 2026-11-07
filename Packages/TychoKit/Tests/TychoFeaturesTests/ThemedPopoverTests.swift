#if os(macOS)
import AppKit
import SwiftUI
import Testing

@testable import TychoDesign
@testable import TychoFeatures

@MainActor
struct ThemedPopoverTests {
    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.6))
    }

    private func openPopover(theme: ThemePreference, systemAppearance: NSAppearance.Name) -> (NSWindow, NSWindow?) {
        let store = UserDefaults(suiteName: "ThemedPopoverTests.\(theme.rawValue)")!
        store.set(theme.rawValue, forKey: AppearanceKey.theme)
        let existing = Set(NSApplication.shared.windows.map(ObjectIdentifier.init))
        let root = Color.clear
            .frame(width: 200, height: 200)
            .themedPopover(isPresented: .constant(true)) { Text("Filter").padding() }
            .defaultAppStorage(store)
        let window = NSWindow(contentViewController: NSHostingController(rootView: root))
        window.appearance = NSAppearance(named: systemAppearance)
        window.makeKeyAndOrderFront(nil)
        settle()
        let popover = NSApplication.shared.windows.first {
            !existing.contains(ObjectIdentifier($0)) && String(describing: type(of: $0)).contains("Popover")
                && $0.isVisible
        }
        return (window, popover)
    }

    private func isDark(_ window: NSWindow?) -> Bool? {
        window?.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }

    @Test func popoverFollowsTheForcedLightTheme() {
        let (window, popover) = openPopover(theme: .light, systemAppearance: .darkAqua)
        defer { window.close() }

        #expect(popover != nil)
        #expect(isDark(popover) == false)
    }

    @Test func popoverFollowsTheForcedDarkTheme() {
        let (window, popover) = openPopover(theme: .dark, systemAppearance: .aqua)
        defer { window.close() }

        #expect(popover != nil)
        #expect(isDark(popover) == true)
    }
}
#endif
