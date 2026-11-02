import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct TaskViewGroupingTests {
    private func makeTask(_ number: Int, status: TaskStatus = .todo) -> TaskItem {
        let task = TaskItem(number: number, title: "T\(number)")
        task.status = status
        return task
    }

    private func groups(
        _ grouping: TaskViewGrouping, _ tasks: [TaskItem], members: [Member] = [], projects: [Project] = []
    ) -> [TaskViewGroup] {
        grouping.groups(tasks, members: members, projects: projects, now: referenceNow, calendar: utcCalendar)
    }

    @Test func statusAndPriorityKeepEmptyGroups() {
        let all = [makeTask(1, status: .done)]

        let byStatus = groups(.status, all)
        let byPriority = groups(.priority, all)

        #expect(byStatus.map(\.title) == TaskStatus.allCases.map(\.title))
        #expect(byStatus.map(\.tasks.count) == [0, 0, 0, 0, 1])
        #expect(byPriority.map(\.title) == TaskPriority.allCases.map(\.title))
        #expect(byPriority.map(\.tasks.count) == [0, 0, 0, 0, 1])
    }

    @Test func otherGroupingsHideEmptyGroups() throws {
        let context = try makeTestContext()
        let ann = Member(name: "Ann", email: "")
        let bob = Member(name: "Bob", email: "")
        let first = makeTask(1)
        let project = Project(key: "A", name: "A")
        let idle = Project(key: "B", name: "B")
        [ann, bob].forEach(context.insert)
        [project, idle].forEach(context.insert)
        context.insert(first)
        first.assignee = ann
        first.project = project

        #expect(groups(.assignee, [first], members: [ann, bob]).map(\.title) == ["Ann"])
        #expect(groups(.project, [first], projects: [project, idle]).map(\.title) == ["A"])
        #expect(groups(.due, [first]).map(\.title) == ["No due date"])
    }

    @Test func noGroupingIsASingleAllTasksGroup() {
        let all = [makeTask(1), makeTask(2)]

        let result = groups(.none, all)

        #expect(result.count == 1)
        #expect(result.first?.title == "All tasks")
        #expect(result.first?.tasks.count == 2)
    }

    @Test func assigneeGroupsPutUnassignedLast() throws {
        let context = try makeTestContext()
        let zed = Member(name: "Zed", email: "")
        let ann = Member(name: "Ann", email: "")
        let owned = makeTask(1)
        let free = makeTask(2)
        let other = makeTask(3)
        [zed, ann].forEach(context.insert)
        [owned, free, other].forEach(context.insert)
        owned.assignee = zed
        other.assignee = ann

        let result = groups(.assignee, [free, owned, other], members: [zed, ann])

        #expect(result.map(\.title) == ["Ann", "Zed", "Unassigned"])
        #expect(result.last?.tasks.map(\.title) == ["T2"])
    }

    @Test func projectGroupsFollowSortOrder() throws {
        let context = try makeTestContext()
        let late = Project(key: "L", name: "Late")
        let early = Project(key: "E", name: "Early")
        late.sortOrder = 2
        early.sortOrder = 1
        let first = makeTask(1)
        let second = makeTask(2)
        [late, early].forEach(context.insert)
        [first, second].forEach(context.insert)
        first.project = late
        second.project = early

        #expect(groups(.project, [first, second], projects: [late, early]).map(\.title) == ["Early", "Late"])
    }

    @Test func dueGroupsFollowBucketOrder() {
        let overdue = makeTask(1)
        let today = makeTask(2)
        let week = makeTask(3)
        let later = makeTask(4)
        let none = makeTask(5)
        overdue.due = day(-3)
        today.due = day(0)
        week.due = day(3)
        later.due = day(20)

        let result = groups(.due, [none, later, week, today, overdue])

        #expect(result.map(\.title) == ["Overdue", "Today", "Next 7 days", "Later", "No due date"])
        #expect(result.map { $0.tasks.map(\.title) } == [["T1"], ["T2"], ["T3"], ["T4"], ["T5"]])
    }

    @Test func dueGroupsPlaceATaskInItsFirstBucketOnly() {
        let task = makeTask(1)
        task.due = day(0)

        #expect(groups(.due, [task]).map(\.title) == ["Today"])
    }

    @Test func titlesMatchTheMenu() {
        #expect(
            TaskViewGrouping.allCases.map(\.title) == [
                "Status", "Priority", "Assignee", "Project", "Due date", "No grouping",
            ]
        )
    }
}
