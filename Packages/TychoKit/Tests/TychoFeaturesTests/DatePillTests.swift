import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct DatePillTests {
    @Test(arguments: WeekStart.allCases)
    func pickerCalendarFollowsTheStartWeekPreference(weekStart: WeekStart) {
        #expect(Calendar.picker(weekStart: weekStart).firstWeekday == weekStart.weekday)
    }

    @Test func committedDatesLandOnNoonOfTheSameDay() {
        let calendar = DateText.gregorian
        let morning = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 3))!
        let committed = DatePill.normalized(morning)
        #expect(
            calendar.dateComponents([.year, .month, .day, .hour], from: committed)
                == DateComponents(year: 2026, month: 10, day: 20, hour: 12))
    }
}
