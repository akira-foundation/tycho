import SwiftUI
import Testing

@testable import TychoFeatures

@MainActor
struct PaletteKeysTests {
    @Test func arrowsWrapAroundTheItems() {
        var state = PaletteState(mode: .commands)
        #expect(PaletteKeys.apply(.upArrow, to: &state, itemCount: 3) == .handled)
        #expect(state.highlight == 2)
        #expect(PaletteKeys.apply(.downArrow, to: &state, itemCount: 3) == .handled)
        #expect(state.highlight == 0)
    }

    @Test func returnRunsAndEscapeCloses() {
        var state = PaletteState(mode: .search)
        #expect(PaletteKeys.apply(.return, to: &state, itemCount: 1) == .run)
        #expect(PaletteKeys.apply(.escape, to: &state, itemCount: 1) == .close)
    }

    @Test func tabTogglesTheModeAndResetsTheHighlight() {
        var state = PaletteState(mode: .commands)
        state.highlight = 2
        #expect(PaletteKeys.apply(.tab, to: &state, itemCount: 4) == .handled)
        #expect(state.mode == .search)
        #expect(state.highlight == 0)
    }

    @Test func deleteReturnsToCommandsOnlyWithAnEmptySearch() {
        var typed = PaletteState(mode: .search)
        typed.query = "a"
        #expect(PaletteKeys.apply(.delete, to: &typed, itemCount: 1) == .ignored)
        var commands = PaletteState(mode: .commands)
        #expect(PaletteKeys.apply(.delete, to: &commands, itemCount: 1) == .ignored)
        var empty = PaletteState(mode: .search)
        #expect(PaletteKeys.apply(.delete, to: &empty, itemCount: 1) == .handled)
        #expect(empty.mode == .commands)
    }

    #if os(macOS)
    @Test func monitorRoutesTheNavigationKeyCodes() {
        #expect(PaletteKeyMonitor.key(forKeyCode: 125) == .downArrow)
        #expect(PaletteKeyMonitor.key(forKeyCode: 126) == .upArrow)
        #expect(PaletteKeyMonitor.key(forKeyCode: 48) == .tab)
        #expect(PaletteKeyMonitor.key(forKeyCode: 53) == .escape)
        #expect(PaletteKeyMonitor.key(forKeyCode: 51) == .delete)
        #expect(PaletteKeyMonitor.key(forKeyCode: 36) == nil)
    }
    #endif
}
