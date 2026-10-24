import Foundation
import Testing

@testable import TychoCore

struct TimelineLayoutTests {
    private let weeks = TimelineLayout(zoom: .week, today: referenceNow, weekStart: .monday, calendar: utcCalendar)
    private let months = TimelineLayout(zoom: .month, today: referenceNow, weekStart: .monday, calendar: utcCalendar)

    @Test func rangesStartOnAWeekBeforeToday() {
        #expect(weeks.rangeStart == utcDate(2026, 9, 21))
        #expect(weeks.width == 2912)
        #expect(weeks.todayX == 704)
        #expect(weeks.todayLineX == 720)
        #expect(weeks.initialScrollX == 544)
        #expect(months.rangeStart == utcDate(2026, 8, 17))
        #expect(months.width == 2618)
        #expect(months.todayX == 627)
    }

    @Test func barsSpanInclusiveDaysAndNeverStartAfterTheDue() {
        #expect(weeks.barFrame(start: day(-2), due: day(1)) == BarFrame(x: 640, width: 128))
        #expect(weeks.barFrame(start: nil, due: day(1)) == BarFrame(x: 736, width: 32))
        #expect(weeks.barFrame(start: day(3), due: day(1)) == BarFrame(x: 736, width: 32))
        #expect(weeks.barStart(start: day(3), due: day(1)) == day(1))
    }

    @Test func monthBlocksCoverTheRange() {
        #expect(weeks.monthBlocks.map(\.title) == ["September 2026", "October 2026", "November 2026", "December 2026"])
        #expect(weeks.monthBlocks.map(\.x) == [0, 320, 1312, 2272])
        #expect(weeks.monthBlocks.map(\.width) == [320, 992, 960, 640])
    }

    @Test func headerCellsAreDaysInWeeksAndWeeksInMonths() {
        #expect(weeks.headerCells.count == 91)
        #expect(weeks.headerCells[0].title == "21")
        #expect(weeks.headerCells[22].title == "13")
        #expect(weeks.headerCells.filter(\.isToday).map(\.x) == [704])
        #expect(months.headerCells.count == 34)
        #expect(months.headerCells.prefix(2).map(\.title) == ["Aug 17", "Aug 24"])
        #expect(months.headerCells[0].width == 77)
    }

    @Test func weekendsAndWeekLines() {
        #expect(weeks.weekendXs.count == 26)
        #expect(weeks.weekendXs.prefix(2) == [160, 192])
        #expect(months.weekendXs.isEmpty)
        #expect(weeks.weekLineXs.count == 13)
        #expect(weeks.weekLineXs[1] == 224)
    }

    @Test func dragsSnapToWholeDays() {
        #expect(weeks.dayOffset(forDrag: 47) == 1)
        #expect(weeks.dayOffset(forDrag: 50) == 2)
        #expect(weeks.dayOffset(forDrag: -40) == -1)
        #expect(weeks.dayOffset(forDrag: 10) == 0)
    }

    @Test func optionsFollowTheOriginal() {
        #expect(TimelineZoom.allCases.map(\.title) == ["Weeks", "Months"])
        #expect(
            TimelineGrouping.allCases.map(\.title) == [
                "Group: Status", "Group: Assignee", "Group: Project", "No grouping",
            ])
        #expect(TimelineGrouping.project.effective(inProject: true) == .status)
        #expect(TimelineGrouping.project.effective(inProject: false) == .project)
        #expect(TimelineGrouping.assignee.effective(inProject: true) == .assignee)
    }
}
