import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct KeyChordTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func press(_ key: Character, _ chord: inout KeyChord, after seconds: TimeInterval = 0) -> ShortcutAction? {
        chord.handle(key, at: start.addingTimeInterval(seconds), isEditingText: false, hasSheet: false)
    }

    @Test func singleKeysMapOutsideFields() {
        var chord = KeyChord()
        #expect(press("/", &chord) == .search)
        #expect(press("n", &chord) == .newTask)
        #expect(press("N", &chord) == .newTask)
        #expect(press("p", &chord) == .newProject)
        #expect(press("?", &chord) == .shortcuts)
        #expect(press("[", &chord) == .toggleSidebar)
        #expect(press("x", &chord) == nil)
    }

    @Test func gThenKeyNavigatesWithinTheWindow() {
        let expected: [(Character, ShortcutAction)] = [
            ("h", .go(.home)), ("t", .go(.myTasks)), ("p", .go(.projects)), ("c", .go(.calendar)), ("S", .settings),
        ]
        for (key, action) in expected {
            var chord = KeyChord()
            #expect(press("g", &chord) == nil)
            #expect(chord.isArmed(at: start.addingTimeInterval(1.1)))
            #expect(press(key, &chord, after: 1.1) == action)
            #expect(!chord.isArmed(at: start.addingTimeInterval(1.1)))
        }
    }

    @Test func gChordExpiresAfterOnePointTwoSeconds() {
        var chord = KeyChord()
        #expect(press("g", &chord) == nil)
        #expect(!chord.isArmed(at: start.addingTimeInterval(1.2)))
        #expect(press("p", &chord, after: 1.2) == .newProject)
        #expect(press("G", &chord, after: 2) == nil)
        #expect(press("h", &chord, after: 3.5) == nil)
    }

    @Test func unknownSecondKeyIsConsumed() {
        var chord = KeyChord()
        #expect(press("g", &chord) == nil)
        #expect(press("n", &chord, after: 0.3) == nil)
        #expect(!chord.isArmed(at: start))
        #expect(press("n", &chord, after: 0.5) == .newTask)
    }

    @Test func nothingFiresWhileEditingText() {
        var chord = KeyChord()
        for key: Character in ["/", "n", "p", "?", "[", "g", "h"] {
            #expect(chord.handle(key, at: start, isEditingText: true, hasSheet: false) == nil)
        }
        #expect(press("g", &chord) == nil)
        #expect(chord.handle("h", at: start, isEditingText: true, hasSheet: false) == nil)
        #expect(!chord.isArmed(at: start))
        #expect(press("h", &chord) == nil)
    }

    @Test func nothingFiresWithASheetOpen() {
        var chord = KeyChord()
        for key: Character in ["/", "n", "p", "?", "[", "g", "t"] {
            #expect(chord.handle(key, at: start, isEditingText: false, hasSheet: true) == nil)
        }
        #expect(press("g", &chord) == nil)
        #expect(chord.handle("c", at: start, isEditingText: false, hasSheet: true) == nil)
        #expect(!chord.isArmed(at: start))
    }

    @Test func catalogMatchesTheSpecGroups() {
        let groups = ShortcutCatalog.groups
        #expect(groups.map(\.title) == ["General", "Create", "Navigate", "Command menu"])
        let flattened = groups.map { group in group.entries.map { "\($0.label): \($0.keys.joined(separator: " "))" } }
        #expect(
            flattened == [
                [
                    "Command menu: ⌘ K", "Search: /", "Keyboard shortcuts: ?", "Toggle sidebar: [",
                    "Toggle dark mode: ⌘ ⇧ L", "Close panel or dialog: Esc",
                ],
                ["New task: N", "New project: P", "Submit form: ⌘ ↵"],
                [
                    "Go to Home: G H", "Go to My Tasks: G T", "Go to Projects: G P", "Go to Calendar: G C",
                    "Go to Settings: G S",
                ],
                ["Move selection: ↑ ↓", "Run command: ↵", "Search mode: Tab"],
            ])
    }

    @Test func routerPerformsEachAction() {
        let router = Router()
        router.perform(.search)
        #expect(router.palette?.mode == .search)
        router.perform(.palette)
        #expect(router.palette == nil)
        router.perform(.palette)
        #expect(router.palette?.mode == .commands)
        router.closePalette()
        router.perform(.go(.calendar))
        #expect(router.route == .calendar)
        router.perform(.toggleSidebar)
        #expect(router.columnVisibility == .detailOnly)
        router.perform(.toggleSidebar)
        #expect(router.columnVisibility == .all)
        router.perform(.shortcuts)
        #expect(router.isShowingShortcuts)
        router.perform(.settings)
        #expect(router.isShowingSettings)
        router.perform(.newTask)
        router.perform(.newProject)
        #expect(router.isCreatingTask && router.isCreatingProject)
    }

    @Test func routerReportsModalPresentationAndEditingFields() {
        let router = Router()
        #expect(!router.hasModalPresentation)
        router.openPalette(mode: .commands)
        #expect(router.hasModalPresentation)
        router.closePalette()
        router.isShowingShortcuts = true
        #expect(router.hasModalPresentation)
        router.isShowingShortcuts = false
        let first = UUID()
        let second = UUID()
        router.markEditing(first, true)
        router.markEditing(second, true)
        router.markEditing(first, false)
        #expect(router.isEditingText)
        router.markEditing(second, false)
        #expect(!router.isEditingText)
    }
}
