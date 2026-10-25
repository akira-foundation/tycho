import SwiftUI
import Testing

@testable import TychoDesign

@MainActor
struct ButtonStyleTests {
    @Test func primaryTextUsesTheOnAccentToken() {
        #expect(ButtonVariant.primary.foreground(isDark: false) == Token.onAccent.light)
        #expect(ButtonVariant.primary.foreground(isDark: true) == Token.onAccent.dark)
    }

    @Test func dangerTextUsesTheOnAccentToken() {
        #expect(ButtonVariant.danger.foreground(isDark: false) == Token.onAccent.light)
        #expect(ButtonVariant.danger.foreground(isDark: true) == Token.onAccent.dark)
    }

    @Test func variantsMapToTheOriginalForegrounds() {
        #expect(ButtonVariant.secondary.foreground(isDark: false) == Token.text.light)
        #expect(ButtonVariant.ghost.foreground(isDark: true) == Token.text2.dark)
        #expect(ButtonVariant.dangerGhost.foreground(isDark: false) == Token.red.light)
    }

    @Test func onlyTheSecondaryVariantHasABorder() {
        let bordered = ButtonVariant.allCases.filter(\.hasBorder)
        #expect(bordered == [.secondary])
    }

    @Test func sizesFollowTheOriginalHeights() {
        #expect(ButtonSize.sm.height == 26)
        #expect(ButtonSize.md.height == 30)
        #expect(ButtonSize.lg.height == 36)
        #expect([ButtonSize.sm, .md, .lg].map(\.horizontalPadding) == [8, 11, 14])
    }

    @Test func stylesBuildABody() {
        _ = Button("Save") {}.buttonStyle(TychoButtonStyle(.primary, size: .lg, block: true))
        _ = Toggle("On", isOn: .constant(true)).toggleStyle(TychoToggleStyle())
    }
}
