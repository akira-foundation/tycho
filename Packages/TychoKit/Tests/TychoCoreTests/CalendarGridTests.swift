import Foundation
import Testing

@testable import TychoCore

struct CalendarGridTests {
    private func month(_ weekStart: WeekStart) -> [CalendarCell] {
        CalendarGrid.month(containing: referenceNow, weekStart: weekStart, today: referenceNow, calendar: utcCalendar)
    }

    @Test func mondayWeeksTrimTheSixthRowWhenItIsOutsideTheMonth() {
        let cells = month(.monday)
        #expect(cells.count == 35)
        #expect(cells.first?.key == "2026-09-28")
        #expect(cells[3].key == "2026-10-01")
        #expect(cells.last?.key == "2026-11-01")
        #expect(cells.filter(\.isInMonth).count == 31)
        #expect(cells.filter(\.isToday).map(\.key) == ["2026-10-13"])
        #expect(cells.first?.isInMonth == false)
    }

    @Test func sundayWeeksStartTheDayBefore() {
        let cells = month(.sunday)
        #expect(cells.count == 35)
        #expect(cells.first?.key == "2026-09-27")
        #expect(cells.last?.key == "2026-10-31")
    }

    @Test func saturdayWeeksKeepSixRowsWhenTheMonthSpillsOver() {
        let cells = month(.saturday)
        #expect(cells.count == 42)
        #expect(cells.first?.key == "2026-09-26")
        #expect(cells[35].key == "2026-10-31")
        #expect(cells.last?.key == "2026-11-06")
    }

    @Test func weekdayLabelsRotateWithTheWeekStart() {
        #expect(CalendarGrid.weekdayLabels(weekStart: .monday) == ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
        #expect(CalendarGrid.weekdayLabels(weekStart: .sunday) == ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
        #expect(CalendarGrid.weekdayLabels(weekStart: .saturday) == ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"])
    }

    @Test func weeksStartOnTheChosenDay() {
        let monday = CalendarGrid.week(
            containing: referenceNow, weekStart: .monday, today: referenceNow, calendar: utcCalendar)
        let sunday = CalendarGrid.week(
            containing: referenceNow, weekStart: .sunday, today: referenceNow, calendar: utcCalendar)
        #expect(monday.map(\.key).first == "2026-10-12")
        #expect(monday.map(\.key).last == "2026-10-18")
        #expect(monday.allSatisfy { $0.isInMonth })
        #expect(sunday.first?.key == "2026-10-11")
        #expect(monday[1].isToday)
    }

    @Test func titlesFollowTheOriginal() {
        #expect(
            CalendarGrid.title(.month, anchor: referenceNow, weekStart: .monday, calendar: utcCalendar)
                == "October 2026")
        #expect(
            CalendarGrid.title(.week, anchor: referenceNow, weekStart: .monday, calendar: utcCalendar)
                == "Oct 12 – Oct 18, 2026")
        #expect(
            CalendarGrid.title(.week, anchor: utcDate(2026, 12, 31), weekStart: .monday, calendar: utcCalendar)
                == "Dec 28 – Jan 3, 2027")
    }

    @Test func steppingMovesByWholeMonthsAndWeeks() {
        #expect(CalendarGrid.step(referenceNow, mode: .month, by: 1, calendar: utcCalendar) == utcDate(2026, 11, 1))
        #expect(CalendarGrid.step(referenceNow, mode: .month, by: -1, calendar: utcCalendar) == utcDate(2026, 9, 1))
        #expect(
            CalendarGrid.step(utcDate(2026, 1, 31), mode: .month, by: 1, calendar: utcCalendar) == utcDate(2026, 2, 1))
        #expect(CalendarGrid.step(referenceNow, mode: .week, by: 1, calendar: utcCalendar) == utcDate(2026, 10, 20))
    }
}
