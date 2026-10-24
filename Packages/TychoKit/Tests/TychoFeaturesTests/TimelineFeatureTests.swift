import CoreGraphics
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct TimelineFeatureTests {
    @Test func timelinePointsBecomeCanvasPoints() {
        #expect(TimelinePoint(x: 3, y: 4.5).point == CGPoint(x: 3, y: 4.5))
    }

    @Test func barsUseTheProjectColorOnlyWhenGroupedByStatusOrNothing() {
        #expect(TimelineBarTint.source(for: .status) == .project)
        #expect(TimelineBarTint.source(for: .none) == .project)
        #expect(TimelineBarTint.source(for: .assignee) == .status)
        #expect(TimelineBarTint.source(for: .project) == .status)
    }

    @Test func titlesGoInsideOnlyBarsWiderThan110() {
        #expect(!TimelineBar.showsTitleInside(width: 110))
        #expect(TimelineBar.showsTitleInside(width: 111))
    }

    @Test func dragOffsetIgnoresNonFiniteTranslations() {
        let layout = TimelineLayout(zoom: .week, today: .now, weekStart: .monday, calendar: DateText.gregorian)
        #expect(layout.dayOffset(forDrag: .nan) == 0)
        #expect(layout.dayOffset(forDrag: .infinity) == 0)
        #expect(layout.dayOffset(forDrag: -.infinity) == 0)
        #expect(layout.dayOffset(forDrag: 64) == 2)
    }
}
