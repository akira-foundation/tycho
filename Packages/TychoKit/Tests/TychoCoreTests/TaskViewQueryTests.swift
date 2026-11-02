import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct TaskViewQueryTests {
    private func makeTask(
        _ number: Int, _ title: String, status: TaskStatus = .todo, priority: TaskPriority = .noPriority
    ) -> TaskItem {
        let task = TaskItem(number: number, title: title)
        task.status = status
        task.priority = priority
        task.sortOrder = Double(number)
        return task
    }

    private func titles(_ query: TaskViewQuery, _ tasks: [TaskItem]) -> [String] {
        query.apply(tasks, now: referenceNow, calendar: utcCalendar).map(\.title)
    }

    @Test func filtersAreAndedAndValuesOred() {
        let all = [
            makeTask(1, "A", status: .todo, priority: .high),
            makeTask(2, "B", status: .progress, priority: .high),
            makeTask(3, "C", status: .done, priority: .high),
            makeTask(4, "D", status: .todo, priority: .low),
        ]
        let query = TaskViewQuery(filters: [
            TaskFilter(field: .status, values: ["todo", "progress"]),
            TaskFilter(field: .priority, values: ["high"]),
        ])

        #expect(titles(query, all) == ["A", "B"])
    }

    @Test func searchMatchesTitleOrKeyCaseInsensitive() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Web")
        let first = makeTask(1, "Prepare design system tokens")
        let second = makeTask(2, "Other")
        context.insert(project)
        context.insert(first)
        context.insert(second)
        first.project = project
        second.project = project

        #expect(titles(TaskViewQuery(query: "web-1"), [first, second]) == ["Prepare design system tokens"])
        #expect(titles(TaskViewQuery(query: "  TOKENS "), [first, second]) == ["Prepare design system tokens"])
    }

    @Test func searchIgnoresNotes() {
        let task = makeTask(1, "A")
        task.notes = "secret"

        #expect(titles(TaskViewQuery(query: "secret"), [task]).isEmpty)
    }

    @Test func sortAppliesAfterFilteringWithManualTieBreak() {
        let all = [
            makeTask(3, "C", status: .todo, priority: .high),
            makeTask(1, "A", status: .todo, priority: .high),
            makeTask(2, "B", status: .done, priority: .urgent),
            makeTask(4, "D", status: .todo, priority: .urgent),
        ]
        let query = TaskViewQuery(
            filters: [TaskFilter(field: .status, values: ["todo"])],
            sort: TaskComparator(field: .priority)
        )

        #expect(titles(query, all) == ["D", "A", "C"])
    }

    @Test func updatedSortsNewestFirstAscending() {
        let old = makeTask(1, "Old")
        let recent = makeTask(2, "Recent")
        old.updatedAt = day(-5)
        recent.updatedAt = day(-1)

        #expect(titles(TaskViewQuery(sort: TaskComparator(field: .updated)), [old, recent]) == ["Recent", "Old"])
        #expect(
            titles(TaskViewQuery(sort: TaskComparator(field: .updated, order: .reverse)), [recent, old])
                == ["Old", "Recent"]
        )
    }

    @Test func nilSortKeepsManualOrder() {
        let all = [makeTask(2, "B"), makeTask(1, "A")]

        #expect(titles(TaskViewQuery(), all) == ["A", "B"])
    }

    @Test func menuOrderListsEverySortOption() {
        #expect(
            TaskSortField.menuOrder.map(\.title) == [
                "Manual", "Priority", "Due date", "Start date", "Title", "Status", "Assignee", "Created",
                "Last updated",
            ]
        )
    }
}
