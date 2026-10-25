import SwiftUI
import Testing

@testable import TychoDesign

@MainActor
struct ComponentTests {
    @Test func priorityBarsFollowTheWeight() {
        #expect([0, 1, 2, 3, 4].map(PriorityIcon.filledBars(for:)) == [0, 1, 2, 3, 3])
    }

    @Test func progressRingClampsItsFraction() {
        #expect(ProgressRing.fraction(-5) == 0)
        #expect(ProgressRing.fraction(45) == 0.45)
        #expect(ProgressRing.fraction(140) == 1)
    }

    @Test func componentsBuildABody() {
        _ = StatusIcon(glyph: .partial(0.45), color: .orange).body
        _ = PriorityIcon(weight: 4).body
        _ = LabelPill(title: "Design", color: .purple).body
        _ = Avatar(initials: "SC", color: .pink).body
        _ = AvatarStack(people: [("SC", .pink), ("JC", .blue)]).body
        _ = ProgressRing(percent: 50, color: .green).body
        _ = StatCard(title: "Overdue", symbol: "clock", value: "3", detail: "need attention", tone: .red) {}.body
        _ = ProjectGlyph(symbol: "globe", color: .indigo).body
        _ = EmptyState(title: "No tasks", symbol: "tray", message: "Nothing here yet").body
    }
}
