import Foundation
import SwiftUI
import Testing
import TychoDesign

@testable import TychoFeatures

@MainActor
struct PaletteHighlightTests {
    @Test func boldsTheFirstCaseInsensitiveMatchOnly() throws {
        let title = PaletteHighlight.title("Homepage home", query: "HOME")
        let bold = title.runs.filter { $0.inlinePresentationIntent == .stronglyEmphasized }
        let run = try #require(bold.first)
        #expect(bold.count == 1)
        #expect(String(title[run.range].characters) == "Home")
        #expect(run.foregroundColor == Color.accentColor)
    }

    @Test func leavesTheTitlePlainWithoutAMatch() {
        let empty = PaletteHighlight.title("Homepage", query: "  ")
        let missing = PaletteHighlight.title("Homepage", query: "zzz")
        #expect(empty.runs.allSatisfy { $0.inlinePresentationIntent == nil })
        #expect(missing.runs.allSatisfy { $0.inlinePresentationIntent == nil })
    }

    @Test func themeToggleFlipsTheResolvedScheme() {
        #expect(ThemePreference.toggled(isDark: true) == .light)
        #expect(ThemePreference.toggled(isDark: false) == .dark)
        #expect(ThemePreference.dark.resolvesDark)
        #expect(!ThemePreference.light.resolvesDark)
    }
}
