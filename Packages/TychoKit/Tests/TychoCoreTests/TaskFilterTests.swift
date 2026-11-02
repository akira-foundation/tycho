import Foundation
import Testing

@testable import TychoCore

@MainActor
struct TaskFilterTests {
    private func matches(_ filter: TaskFilter, _ task: TaskItem) -> Bool {
        filter.matches(task, now: referenceNow, calendar: utcCalendar)
    }

    @Test func emptyValuesMatchEverythingEvenWhenNegated() {
        let task = TaskItem(number: 1, title: "A")

        #expect(matches(TaskFilter(field: .status, op: .isNot, values: []), task))
    }

    @Test func statusIsAndIsNot() {
        let task = TaskItem(number: 1, title: "A")
        task.status = .progress

        #expect(matches(TaskFilter(field: .status, op: .is, values: ["progress"]), task))
        #expect(!matches(TaskFilter(field: .status, op: .isNot, values: ["progress"]), task))
    }

    @Test func labelsMatchAny() {
        let task = TaskItem(number: 1, title: "A")
        task.labels = [.design, .qa]

        #expect(matches(TaskFilter(field: .labels, op: .is, values: ["qa", "bug"]), task))
        #expect(!matches(TaskFilter(field: .labels, op: .is, values: ["bug"]), task))
    }

    @Test func unassignedCountsAsNone() {
        let task = TaskItem(number: 1, title: "A")

        #expect(matches(TaskFilter(field: .assignee, op: .is, values: [TaskFilter.noAssignee]), task))
    }

    @Test func assigneeMatchesMemberID() throws {
        let context = try makeTestContext()
        let member = Member(name: "Ann", email: "")
        let task = TaskItem(number: 1, title: "A")
        context.insert(member)
        context.insert(task)
        task.assignee = member

        #expect(matches(TaskFilter(field: .assignee, op: .is, values: [member.id.uuidString]), task))
        #expect(!matches(TaskFilter(field: .assignee, op: .is, values: [TaskFilter.noAssignee]), task))
    }

    @Test func aDeletedMemberFilterMatchesNothing() {
        let task = TaskItem(number: 1, title: "A")

        #expect(!matches(TaskFilter(field: .assignee, op: .is, values: [UUID().uuidString]), task))
    }

    @Test func projectMatchesProjectID() throws {
        let context = try makeTestContext()
        let project = Project(key: "TY", name: "Tycho")
        let task = TaskItem(number: 1, title: "A")
        context.insert(project)
        context.insert(task)
        task.project = project

        #expect(matches(TaskFilter(field: .project, op: .is, values: [project.id.uuidString]), task))
        #expect(!matches(TaskFilter(field: .project, op: .is, values: [UUID().uuidString]), task))
    }

    @Test(
        arguments: [
            (-1, TaskStatus.todo, Set<DueBucket>([.overdue])),
            (-1, TaskStatus.done, Set<DueBucket>()),
            (0, TaskStatus.todo, Set<DueBucket>([.today, .week])),
            (7, TaskStatus.todo, Set<DueBucket>([.week])),
            (8, TaskStatus.todo, Set<DueBucket>([.later])),
        ])
    func dueBuckets(offset: Int, status: TaskStatus, expected: Set<DueBucket>) {
        let task = TaskItem(number: 1, title: "A")
        task.due = day(offset)
        task.status = status

        #expect(DueBucket.bucket(for: task, now: referenceNow, calendar: utcCalendar) == expected)
    }

    @Test func taskWithoutDueDateIsInNoDateBucket() {
        let task = TaskItem(number: 1, title: "A")

        #expect(DueBucket.bucket(for: task, now: referenceNow, calendar: utcCalendar) == [.nodate])
        #expect(matches(TaskFilter(field: .due, op: .is, values: ["nodate"]), task))
    }

    @Test func dueBucketsCountCalendarDaysAcrossDST() {
        var lisbon = Calendar(identifier: .gregorian)
        lisbon.timeZone = TimeZone(identifier: "Europe/Lisbon")!
        let now = lisbon.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: 23, minute: 30))!
        let due = lisbon.date(from: DateComponents(year: 2026, month: 10, day: 26, hour: 0, minute: 30))!
        let task = TaskItem(number: 1, title: "A")
        task.due = due

        let buckets = DueBucket.bucket(for: task, now: now, calendar: lisbon)

        #expect(buckets.contains(.week))
        #expect(!buckets.contains(.today))
    }

    @Test func dueFilterMatchesAnySelectedBucket() {
        let task = TaskItem(number: 1, title: "A")
        task.due = day(0)

        #expect(matches(TaskFilter(field: .due, op: .is, values: ["overdue", "today"]), task))
        #expect(!matches(TaskFilter(field: .due, op: .is, values: ["later"]), task))
    }

    @Test func createdAndUpdatedWindows() {
        let task = TaskItem(number: 1, title: "A")
        task.createdAt = referenceNow.addingTimeInterval(-2 * 86400)
        task.updatedAt = referenceNow.addingTimeInterval(-3600)

        #expect(matches(TaskFilter(field: .created, op: .is, values: ["7"]), task))
        #expect(matches(TaskFilter(field: .created, op: .is, values: ["30"]), task))
        #expect(!matches(TaskFilter(field: .created, op: .is, values: ["1"]), task))
        #expect(matches(TaskFilter(field: .updated, op: .is, values: ["1"]), task))
    }

    @Test func filtersRoundTripThroughJSON() throws {
        let filters = [
            TaskFilter(field: .status, op: .isNot, values: ["done"]),
            TaskFilter(field: .labels, op: .is, values: ["qa", "bug"]),
        ]

        let decoded = try JSONDecoder().decode([TaskFilter].self, from: JSONEncoder().encode(filters))

        #expect(decoded == filters)
    }

    @Test func vocabularyTitles() {
        #expect(TaskFilterField.due.title == "Due date")
        #expect(TaskFilterField.updated.symbol == "clock.arrow.circlepath")
        #expect(TaskFilterOperator.isNot.title == "is not")
        #expect(DueBucket.week.title == "Next 7 days")
        #expect(RecencyWindow.day.title == "Last 24 hours")
    }
}
