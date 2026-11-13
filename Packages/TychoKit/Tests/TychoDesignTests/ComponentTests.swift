import SwiftUI
import Testing

@testable import TychoDesign

@MainActor
struct ComponentTests {
    @Test func priorityBarsFollowTheWeight() {
        #expect([0, 1, 2, 3, 4].map(PriorityIcon.filledBars(for:)) == [0, 1, 2, 3, 3])
    }

    @Test func componentsBuildABody() {
        _ = StatusIcon(glyph: .partial(0.45), color: .orange).body
        _ = PriorityIcon(weight: 4).body
        _ = LabelPill(title: "Design", color: .purple).body
        _ = Avatar(initials: "SC", color: .pink).body
        _ = AvatarStack(people: [("SC", .pink), ("JC", .blue)]).body
        _ = StatCard(title: "Overdue", symbol: "clock", value: "3", detail: "need attention", tone: .red) {}.body
        _ = ProjectGlyph(symbol: "globe", color: .indigo).body
        _ = EmptyState(title: "No tasks", symbol: "tray", message: "Nothing here yet").body
    }

    @Test func everyGlyphAndWeightBuildsWithSystemStyles() {
        for glyph in [StatusGlyph.dashed, .partial(0.5), .done] {
            _ = StatusIcon(glyph: glyph, color: .green).body
        }
        for weight in 0...4 {
            _ = PriorityIcon(weight: weight).body
        }
        _ = AvatarStack(people: [("SC", .pink), ("JC", .blue), ("EW", .teal), ("LF", .green)], limit: 3).body
    }

    @Test func theMarkRaysScaleToTheFrameFromTheIconGrid() {
        let path = TychoMarkRays().path(in: CGRect(x: 0, y: 0, width: 200, height: 200))
        #expect(TychoMarkRays.segments.count == 8)
        #expect(path.boundingRect.integral == CGRect(x: 24, y: 12, width: 164, height: 160))
        let wide = TychoMarkRays().path(in: CGRect(x: 0, y: 0, width: 200, height: 100))
        #expect(wide.boundingRect.integral == CGRect(x: 12, y: 6, width: 82, height: 80))
    }
}
