import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct MonthPickerTests {
    private let calendar = DateText.gregorian

    private func day(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    @Test func weeksSplitTheMonthIntoRowsOfSeven() {
        var stored = day(2026, 11, 15)
        let picker = MonthPicker(selection: Binding(get: { stored }, set: { stored = $0 }))

        let weeks = MonthPicker.weeks(of: picker.cells(around: stored))

        #expect(weeks.allSatisfy { $0.count == 7 })
        #expect(weeks.flatMap(\.self).contains { $0.isInMonth && $0.day == 30 })
    }

    @Test func onlyTheSelectedDayIsMarked() {
        var stored = day(2026, 11, 15)
        let picker = MonthPicker(selection: Binding(get: { stored }, set: { stored = $0 }))

        let marked = picker.cells(around: stored).filter(picker.isSelected)

        #expect(marked.map(\.key) == ["2026-11-15"])
    }

    @Test func pickingADayStoresNoonOfThatDay() {
        var stored = day(2026, 11, 15)
        let picker = MonthPicker(selection: Binding(get: { stored }, set: { stored = $0 }))

        picker.pick(day(2026, 11, 3, hour: 0))

        #expect(
            calendar.dateComponents([.year, .month, .day, .hour], from: stored)
                == DateComponents(year: 2026, month: 11, day: 3, hour: 12))
    }
}
