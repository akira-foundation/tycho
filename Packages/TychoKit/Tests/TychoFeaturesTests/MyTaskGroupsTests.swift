import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct MyTaskGroupsTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()

    private var now: Date { Date(timeIntervalSince1970: 1_800_000_000) }

    private func task(_ number: Int, dueIn days: Int?, status: TaskStatus = .todo) -> TaskItem {
        let task = TaskItem(number: number, title: "Task \(number)")
        task.status = status
        task.due = days.flatMap { calendar.date(byAdding: .day, value: $0, to: now) }
        return task
    }

    @Test func myTasksGroupsFollowTheOriginal() {
        let late = task(1, dueIn: -2)
        let today = task(2, dueIn: 0)
        let soon = task(3, dueIn: 4)
        let undated = task(4, dueIn: nil)
        let doneLate = task(5, dueIn: -3, status: .done)
        let doneUndated = task(6, dueIn: nil, status: .done)

        let groups = MyTaskGroups.groups(
            [late, today, soon, undated, doneLate, doneUndated], now: now, calendar: calendar)

        #expect(groups.map(\.id) == ["overdue", "today", "upcoming", "completed"])
        #expect(groups.map(\.title) == ["Overdue", "Today", "Upcoming", "Completed"])
        #expect(groups[0].tasks == [late])
        #expect(groups[1].tasks == [today])
        #expect(groups[2].tasks == [soon, undated])
        #expect(groups[3].tasks == [doneLate, doneUndated])
        #expect(MyTaskGroups.initiallyCollapsed == ["completed"])
    }

    @Test func emptyGroupsAreKept() {
        let groups = MyTaskGroups.groups([], now: now, calendar: calendar)

        #expect(groups.map(\.id) == ["overdue", "today", "upcoming", "completed"])
        #expect(groups.flatMap(\.tasks).isEmpty)
    }

    @Test func manualSortBecomesDueSortInMyTasks() {
        var manual = TaskViewState(inProject: false)
        manual.query = "ship"
        var explicitManual = TaskViewState(inProject: false)
        explicitManual.sort = [TaskComparator(field: .manual, order: .reverse)]
        var priority = TaskViewState(inProject: false)
        priority.sort = [TaskComparator(field: .priority, order: .reverse)]

        #expect(MyTaskGroups.query(for: manual).sort == TaskComparator(field: .due))
        #expect(MyTaskGroups.query(for: manual).query == "ship")
        #expect(MyTaskGroups.query(for: explicitManual).sort == TaskComparator(field: .due))
        #expect(MyTaskGroups.query(for: priority).sort == TaskComparator(field: .priority, order: .reverse))
    }

    @Test func dueSortOrdersMyTasksByDeadline() {
        let later = task(1, dueIn: 5)
        let sooner = task(2, dueIn: 1)

        let sorted = MyTaskGroups.query(for: TaskViewState(inProject: false))
            .apply([later, sooner], now: now, calendar: calendar)

        #expect(sorted == [sooner, later])
    }
}
