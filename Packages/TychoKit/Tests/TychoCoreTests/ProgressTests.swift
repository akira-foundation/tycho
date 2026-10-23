import Foundation
import Testing

@testable import TychoCore

@MainActor
struct ProgressTests {
    @Test func taskProgressFollowsTheOriginalRules() {
        let task = TaskItem(number: 1, title: "x")
        task.status = .review
        #expect(task.progress == 80)
        task.subtasks = [Subtask(title: "a", isDone: true), Subtask(title: "b"), Subtask(title: "c")]
        #expect(task.progress == 33)
        task.status = .done
        #expect(task.progress == 100)
    }

    @Test func projectProgressIsTheShareOfDoneTasks() {
        let project = Project(key: "WEB", name: "Web")
        #expect(project.progress == 0)
        let done = TaskItem(number: 1, title: "a")
        done.status = .done
        project.tasks = [done, TaskItem(number: 2, title: "b"), TaskItem(number: 3, title: "c")]
        #expect(project.progress == 33)
    }

    @Test func dueTodayIsNeverOverdueWhateverTheHour() {
        let task = TaskItem(number: 1, title: "x")
        task.due = day(0, hour: 0)
        #expect(!task.isOverdue(now: referenceNow, calendar: utcCalendar))
        task.due = day(0, hour: 23)
        #expect(!task.isOverdue(now: referenceNow, calendar: utcCalendar))
        task.due = day(-1, hour: 23)
        #expect(task.isOverdue(now: referenceNow, calendar: utcCalendar))
        task.status = .done
        #expect(!task.isOverdue(now: referenceNow, calendar: utcCalendar))
    }

    @Test func overdueUsesTheGivenCalendarsDay() {
        var pagoPago = Calendar(identifier: .gregorian)
        pagoPago.timeZone = TimeZone(identifier: "Pacific/Pago_Pago")!
        let task = TaskItem(number: 1, title: "x")
        task.due = day(-1, hour: 13)
        #expect(!task.isOverdue(now: referenceNow, calendar: pagoPago))
        #expect(task.isOverdue(now: referenceNow, calendar: utcCalendar))
    }
}
