import Testing

@testable import TychoFeatures

@MainActor
struct ShortcutKeysTests {
    @Test func gSequencesInsertThen() {
        #expect(ShortcutKeys.tokens(["G", "H"]) == [.key("G"), .then, .key("H")])
    }

    @Test func modifierCombosDoNot() {
        #expect(ShortcutKeys.tokens(["⌘", "⇧", "L"]) == [.key("⌘"), .key("⇧"), .key("L")])
        #expect(ShortcutKeys.tokens(["↑", "↓"]) == [.key("↑"), .key("↓")])
        #expect(ShortcutKeys.tokens(["Esc"]) == [.key("Esc")])
    }

    @Test func everyCatalogEntryYieldsAKeyPerKey() {
        for group in ShortcutCatalog.groups {
            for entry in group.entries {
                let keys = ShortcutKeys.tokens(entry.keys).filter { $0 != .then }
                #expect(keys.count == entry.keys.count)
            }
        }
    }

    @Test func dismissingTheSheetReleasesTheModalState() {
        let router = Router()
        router.showShortcuts()
        #expect(router.isShowingShortcuts)
        #expect(router.hasModalPresentation)
        router.isShowingShortcuts = false
        #expect(!router.hasModalPresentation)
    }
}
