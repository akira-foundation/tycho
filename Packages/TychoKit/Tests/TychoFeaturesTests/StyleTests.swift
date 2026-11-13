import Testing
import TychoDesign

@testable import TychoCore
@testable import TychoFeatures

struct StyleTests {
    @Test func statusGlyphsFollowTheOriginalIcons() {
        #expect(TaskStatus.allCases.map(\.glyph) == [.dashed, .partial(0), .partial(0.5), .partial(0.75), .done])
    }

    @Test func labelTonesFollowTheOriginal() {
        #expect(TaskLabel.allCases.map(\.token) == [.violet, .blue, .teal, .amber, .rose, .red, .green, .orange])
    }

    @Test func projectStatusUsesSystemSymbolsAndColors() {
        #expect(
            ProjectStatus.allCases.map(\.symbol) == [
                "circle.dashed", "circle.lefthalf.filled", "exclamationmark.triangle.fill", "pause.circle.fill",
                "checkmark.circle.fill",
            ])
        #expect(ProjectStatus.allCases.map(\.tint) == [.gray, .blue, .red, .orange, .green])
    }
}
