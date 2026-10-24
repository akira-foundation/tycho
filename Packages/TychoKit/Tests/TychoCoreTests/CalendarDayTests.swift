import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct CalendarDayTests {
    @Test func eventsComeFirstThenTasksDueThatDay() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        let late = TaskItem(number: 1, title: "Late")
        let early = TaskItem(number: 2, title: "Early")
        let other = TaskItem(number: 3, title: "Other day")
        let undated = TaskItem(number: 4, title: "Undated")
        for (offset, task) in [late, early, other, undated].enumerated() {
            context.insert(task)
            task.project = project
            task.sortOrder = Double(offset)
        }
        late.due = day(1, hour: 1)
        early.due = day(1, hour: 23)
        early.sortOrder = -1
        other.due = day(2)
        let review = CalendarEvent(title: "Review", date: day(1), time: "14:00")
        let standup = CalendarEvent(title: "Standup", date: day(1), time: "09:30")
        let retro = CalendarEvent(title: "Retro", date: day(2), time: "16:00")

        let items = CalendarDay.items(
            on: day(1, hour: 0), events: [review, standup, retro], tasks: [late, early, other, undated],
            calendar: utcCalendar)

        #expect(items.map(\.id) == [standup.id, review.id, early.id, late.id])
    }

    @Test func tasksFromDifferentProjectsFollowTheProjectOrder() throws {
        let context = try makeTestContext()
        let first = Project(key: "WEB", name: "Website")
        let second = Project(key: "MOB", name: "Mobile")
        context.insert(first)
        context.insert(second)
        first.sortOrder = 2
        second.sortOrder = 1
        let inFirst = TaskItem(number: 1, title: "A in first")
        let inSecond = TaskItem(number: 2, title: "Z in second")
        for (task, project) in [(inFirst, first), (inSecond, second)] {
            context.insert(task)
            task.project = project
            task.due = day(1)
            task.sortOrder = 0
        }

        let items = CalendarDay.items(on: day(1), events: [], tasks: [inFirst, inSecond], calendar: utcCalendar)

        #expect(items.map(\.id) == [inSecond.id, inFirst.id])
    }

    @Test func equalSortKeysFallBackToTitle() throws {
        let context = try makeTestContext()
        let beta = TaskItem(number: 1, title: "Beta")
        let alpha = TaskItem(number: 2, title: "Alpha")
        for task in [beta, alpha] {
            context.insert(task)
            task.due = day(1)
        }

        let items = CalendarDay.items(on: day(1), events: [], tasks: [beta, alpha], calendar: utcCalendar)

        #expect(items.map(\.id) == [alpha.id, beta.id])
    }

    @Test func chipsShowThreeAndCountTheRest() {
        let events = (0..<5).map { CalendarEvent(title: "E\($0)", date: day(1), time: "10:0\($0)") }
        let chips = CalendarDay.chips(for: events.map(CalendarItem.event))
        #expect(chips.shown.map(\.id) == events.prefix(3).map(\.id))
        #expect(chips.overflow == 2)
        #expect(CalendarDay.chips(for: events.prefix(2).map(CalendarItem.event)).overflow == 0)
    }
}
