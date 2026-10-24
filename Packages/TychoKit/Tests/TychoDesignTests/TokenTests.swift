import SwiftUI
import Testing

@testable import TychoDesign

struct TokenTests {
    @Test func coversEveryColourTokenOfTheOriginal() {
        let css = [
            "bg", "bg-side", "surface", "surface-2", "surface-3", "sunken", "overlay",
            "border", "border-strong", "divider",
            "text", "text-2", "text-3", "text-4", "text-inv", "on-accent",
            "green", "amber", "red", "blue", "violet", "teal", "rose", "orange", "gray",
            "st-backlog", "st-todo", "st-progress", "st-review", "st-done",
        ]
        #expect(Token.allCases.map(\.cssName) == css)
    }

    @Test func keepsTheOriginalValues() {
        #expect(Token.bg.light == RGBA(hex: 0xFBFAF8))
        #expect(Token.bg.dark == RGBA(hex: 0x1A1A19))
        #expect(Token.stProgress.light == RGBA(hex: 0xC88A14))
        #expect(Token.stDone.dark == RGBA(hex: 0x5CBA86))
        #expect(Token.overlay.light == RGBA(hex: 0x181613, alpha: 0.28))
        #expect(Token.overlay.dark == RGBA(hex: 0x000000, alpha: 0.55))
        #expect(Token.onAccent.dark == RGBA(hex: 0xFFFFFF))
    }

    @Test func densityChangesRowAndCardMetrics() {
        #expect(Density.comfortable.metrics == Metrics(rowHeight: 40, cardPadding: 10, sideRow: 30))
        #expect(Density.compact.metrics == Metrics(rowHeight: 34, cardPadding: 8, sideRow: 26))
    }

    @Test func typeScaleKeepsTheOriginalSizes() {
        #expect(TypeScale.allCases.map(\.points) == [11, 12, 12.5, 13.5, 14.5, 16, 19, 23])
    }

    @Test func motionHonoursPreferences() {
        #expect(Motion.animation(Motion.ease, preference: .reduce, reduceMotion: false) == nil)
        #expect(Motion.animation(Motion.ease, preference: .system, reduceMotion: true) == nil)
        #expect(Motion.animation(Motion.ease, preference: .full, reduceMotion: true) != nil)
        #expect(Motion.animation(Motion.ease, preference: .system, reduceMotion: false) != nil)
    }

    @Test func themeMapsToColorScheme() {
        #expect(ThemePreference.system.colorScheme == nil)
        #expect(ThemePreference.light.colorScheme == .light)
        #expect(ThemePreference.dark.colorScheme == .dark)
    }
}
