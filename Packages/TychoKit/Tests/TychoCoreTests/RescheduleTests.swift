import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct RescheduleTests {
    private func setUp() throws -> (TaskItem, TaskActions) {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        let task = try TaskActions(context: context, now: { referenceNow }).create(
            TaskDraft(title: "Wireframes"), in: project)
        return (task, TaskActions(context: context, now: { referenceNow.addingTimeInterval(60) }))
    }

    @Test func rescheduleKeepsTheDuration() throws {
        let (task, actions) = try setUp()
        task.start = day(-2)
        task.due = day(1)
        #expect(try actions.reschedule(task, toDue: day(5, hour: 0), calendar: utcCalendar))
        #expect(task.due == day(5))
        #expect(task.start == day(2))
        #expect(task.updatedAt == referenceNow.addingTimeInterval(60))
    }

    @Test func rescheduleWithoutAStartMovesOnlyTheDue() throws {
        let (task, actions) = try setUp()
        task.due = day(1)
        try actions.reschedule(task, toDue: day(3), calendar: utcCalendar)
        #expect(task.due == day(3))
        #expect(task.start == nil)
    }

    @Test func rescheduleToTheSameDayDoesNothing() throws {
        let (task, actions) = try setUp()
        task.due = day(1)
        let before = task.updatedAt
        #expect(try !actions.reschedule(task, toDue: day(1, hour: 23), calendar: utcCalendar))
        #expect(task.updatedAt == before)
    }

    @Test func rescheduleGivesATaskWithoutDueANoonDue() throws {
        let (task, actions) = try setUp()
        #expect(try actions.reschedule(task, toDue: day(4, hour: 0), calendar: utcCalendar))
        #expect(task.due == day(4))
    }

    @Test func shiftMovesStartAndDue() throws {
        let (task, actions) = try setUp()
        task.start = day(-2)
        task.due = day(1)
        #expect(try actions.shift(task, byDays: -3, calendar: utcCalendar))
        #expect(task.start == day(-5))
        #expect(task.due == day(-2))
    }

    @Test func shiftByZeroOrWithoutDueDoesNothing() throws {
        let (task, actions) = try setUp()
        #expect(try !actions.shift(task, byDays: 2, calendar: utcCalendar))
        task.due = day(1)
        #expect(try !actions.shift(task, byDays: 0, calendar: utcCalendar))
        #expect(task.due == day(1))
    }

    @Test func shiftKeepsTheLocalTimeAcrossADaylightSavingChange() throws {
        var lisbon = Calendar(identifier: .gregorian)
        lisbon.timeZone = TimeZone(identifier: "Europe/Lisbon")!
        let (task, actions) = try setUp()
        task.start = lisbon.date(from: DateComponents(year: 2026, month: 10, day: 18, hour: 12))
        task.due = lisbon.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 12))

        try actions.shift(task, byDays: 14, calendar: lisbon)

        let due = try #require(task.due)
        let start = try #require(task.start)
        #expect(lisbon.component(.month, from: due) == 11)
        #expect(lisbon.component(.day, from: due) == 3)
        #expect(lisbon.component(.hour, from: due) == 12)
        #expect(DayTime.days(from: start, to: due, calendar: lisbon) == 2)
    }

    @Test func noonAndDayDifferences() {
        #expect(DayTime.noon(of: day(3, hour: 23), calendar: utcCalendar) == day(3))
        #expect(DayTime.days(from: day(1, hour: 23), to: day(2, hour: 1), calendar: utcCalendar) == 1)
        #expect(DayTime.days(from: day(2), to: day(-1), calendar: utcCalendar) == -3)
    }
}
