import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct DatePillTests {
    @Test func committedDatesLandOnNoonOfTheSameDay() {
        let calendar = DateText.gregorian
        let morning = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 3))!
        let committed = DatePill.normalized(morning)
        #expect(
            calendar.dateComponents([.year, .month, .day, .hour], from: committed)
                == DateComponents(year: 2026, month: 10, day: 20, hour: 12))
    }

    @Test func closingWithoutEditingCommitsNothing() {
        let stored = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(DatePill.dateToCommit(stored: stored, draft: .now, edited: false) == nil)
    }

    @Test func closingWithAnEditedDraftCommitsTheNormalizedDate() {
        let calendar = DateText.gregorian
        let draft = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 3))!
        let expected = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 12))!
        #expect(DatePill.dateToCommit(stored: nil, draft: draft, edited: true) == expected)
    }

    @Test func closingWithADraftEqualToTheStoredDateCommitsNothing() {
        let calendar = DateText.gregorian
        let stored = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 12))!
        let draft = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 5))!
        #expect(DatePill.dateToCommit(stored: stored, draft: draft, edited: true) == nil)
    }
}
