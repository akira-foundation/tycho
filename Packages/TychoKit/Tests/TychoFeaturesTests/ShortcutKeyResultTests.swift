import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct ShortcutKeyResultTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func receive(
        _ key: Character, _ chord: inout KeyChord, option: Bool = false, editing: Bool = false, sheet: Bool = false
    ) -> ShortcutKeyResult {
        chord.receive(key, hasOption: option, at: start, isEditingText: editing, hasSheet: sheet)
    }

    @Test func actionsAndTheGPrefixAreConsumed() {
        var chord = KeyChord()
        #expect(receive("n", &chord) == ShortcutKeyResult(action: .newTask, consumes: true))
        #expect(receive("g", &chord) == ShortcutKeyResult(action: nil, consumes: true))
        #expect(receive("h", &chord) == ShortcutKeyResult(action: .go(.home), consumes: true))
        #expect(receive("x", &chord) == .passThrough)
    }

    @Test func unknownPrintableKeyAfterGIsConsumed() {
        var chord = KeyChord()
        _ = receive("g", &chord)
        #expect(receive("x", &chord) == ShortcutKeyResult(action: nil, consumes: true))
        #expect(!chord.isArmed(at: start))
    }

    @Test(arguments: ["\u{1B}", "\r", "\t", "\u{7F}", "\u{F700}", "\u{F701}"] as [Character])
    func nonPrintableKeysAfterGPassThroughAndDisarm(_ key: Character) {
        var chord = KeyChord()
        _ = receive("g", &chord)
        #expect(receive(key, &chord) == .passThrough)
        #expect(!chord.isArmed(at: start))
        #expect(receive("h", &chord) == .passThrough)
    }

    @Test func optionIsOnlyAcceptedForTheBracket() {
        var chord = KeyChord()
        #expect(receive("[", &chord, option: true) == ShortcutKeyResult(action: .toggleSidebar, consumes: true))
        #expect(receive("n", &chord, option: true) == .passThrough)
        #expect(receive("g", &chord, option: true) == .passThrough)
        #expect(!chord.isArmed(at: start))
    }

    @Test func nothingIsConsumedWhileEditingOrWithASheet() {
        var chord = KeyChord()
        _ = receive("g", &chord)
        #expect(receive("x", &chord, editing: true) == .passThrough)
        _ = receive("g", &chord)
        #expect(receive("h", &chord, sheet: true) == .passThrough)
        #expect(receive("n", &chord, editing: true) == .passThrough)
    }

    @Test func navigationCommandsAreBlockedByModalsButNotByThePalette() {
        let router = Router()
        #expect(!router.blocksNavigationCommands)
        router.openPalette(mode: .commands)
        #expect(!router.blocksNavigationCommands)
        router.closePalette()
        router.newTask()
        #expect(router.blocksNavigationCommands)
        router.isCreatingTask = false
        router.inspect(UUID())
        router.updateWindowWidth(400)
        #expect(router.blocksNavigationCommands)
    }

    @Test func aLocalSheetBlocksNavigationCommands() {
        let router = Router()
        router.isShowingLocalSheet = true

        #expect(router.hasModalPresentation)
        #expect(router.blocksNavigationCommands)
    }

    @Test func aNewWorkspaceDropsWhatWasRequestedDuringOnboarding() {
        let router = Router()
        router.openPalette(mode: .search)
        router.showShortcuts()
        router.newProject()

        router.resetForNewWorkspace()

        #expect(router.palette == nil)
        #expect(!router.isShowingShortcuts)
        #expect(!router.isCreatingProject)
        #expect(router.route == .home)
    }
}
