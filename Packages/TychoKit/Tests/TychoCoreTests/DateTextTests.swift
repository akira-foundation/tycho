import Foundation
import Testing

@testable import TychoCore

struct DateTextTests {
    private func text(_ format: DateFormatPreference) -> DateText {
        DateText(format: format, now: referenceNow, calendar: utcCalendar)
    }

    @Test func preferencesMatchTheOriginalOptions() {
        #expect(WeekStart.allCases.map(\.title) == ["Monday", "Sunday", "Saturday"])
        #expect(WeekStart.allCases.map(\.weekday) == [2, 1, 7])
        #expect(DateFormatPreference.allCases.map(\.rawValue) == ["MMM d", "d/M", "M/d", "yyyy-MM-dd"])
        #expect(DateFormatPreference.allCases.map(\.example) == ["Oct 1", "1/10", "10/1", "2026-10-01"])
    }

    @Test func shortDatesHideTheCurrentYear() {
        let date = utcDate(2026, 10, 1, hour: 12)
        #expect(text(.monthDay).short(date) == "Oct 1")
        #expect(text(.dayMonth).short(date) == "1/10")
        #expect(text(.monthDayNumeric).short(date) == "10/1")
        #expect(text(.iso).short(date) == "2026-10-01")
    }

    @Test func shortDatesShowAnotherYear() {
        let date = utcDate(2025, 12, 31, hour: 12)
        #expect(text(.monthDay).short(date) == "Dec 31, 2025")
        #expect(text(.dayMonth).short(date) == "31/12/2025")
        #expect(text(.monthDayNumeric).short(date) == "12/31/2025")
        #expect(text(.iso).short(date) == "2025-12-31")
    }

    @Test func longDatesAlwaysShowTheYear() {
        let date = utcDate(2026, 10, 1, hour: 12)
        #expect(text(.monthDay).long(date) == "Oct 1, 2026")
        #expect(text(.dayMonth).long(date) == "1/10/2026")
    }

    @Test func agoMatchesTheOriginalThresholds() {
        let format = text(.monthDay)
        #expect(format.ago(referenceNow.addingTimeInterval(-20)) == "just now")
        #expect(format.ago(referenceNow.addingTimeInterval(-5 * 60)) == "5m ago")
        #expect(format.ago(referenceNow.addingTimeInterval(-90 * 60)) == "2h ago")
        #expect(format.ago(referenceNow.addingTimeInterval(-26 * 3600)) == "1d ago")
        #expect(format.ago(utcDate(2026, 10, 5, hour: 10)) == "Oct 5")
    }
}
