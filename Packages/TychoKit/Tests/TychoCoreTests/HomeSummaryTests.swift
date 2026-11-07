import Foundation
import Testing

@testable import TychoCore

@MainActor
struct HomeSummaryTests {
    private func task(
        _ title: String, _ status: TaskStatus, due: Int?, mine: Bool, priority: TaskPriority = .medium,
        completedHoursAgo: Double? = nil, me: Member, other: Member
    ) -> TaskItem {
        let task = TaskItem(number: 1, title: title)
        task.status = status
        task.priority = priority
        task.due = due.map { day($0) }
        task.assignee = mine ? me : other
        task.completedAt = completedHoursAgo.map { referenceNow.addingTimeInterval(-$0 * 3600) }
        return task
    }

    @Test func countsAndBucketsMatchTheOriginal() {
        let me = Member(name: "Tanjim Islam", email: "", isMe: true)
        let other = Member(name: "Sarah Chen", email: "")
        let active = Project(key: "WEB", name: "Web")
        let risky = Project(key: "LCH", name: "Launch")
        risky.status = .risk
        let complete = Project(key: "MW", name: "Site")
        complete.status = .complete
        let archived = Project(key: "OLD", name: "Old")
        archived.isArchived = true

        let overdueMine = task("late", .todo, due: -2, mine: true, me: me, other: other)
        let today = task("today", .progress, due: 0, mine: false, priority: .low, me: me, other: other)
        let todayUrgent = task("today urgent", .todo, due: 0, mine: true, priority: .urgent, me: me, other: other)
        let tomorrow = task("tomorrow", .review, due: 1, mine: true, me: me, other: other)
        let week = task("week", .todo, due: 7, mine: false, me: me, other: other)
        let farMine = task("far", .backlog, due: 30, mine: true, me: me, other: other)
        let noDueMine = task("someday", .todo, due: nil, mine: true, me: me, other: other)
        let doneRecent = task("done recent", .done, due: -1, mine: true, completedHoursAgo: 30, me: me, other: other)
        let doneOld = task("done old", .done, due: -20, mine: false, completedHoursAgo: 200, me: me, other: other)
        let hidden = task("archived", .todo, due: -5, mine: true, me: me, other: other)
        hidden.project = archived
        let live = [overdueMine, today, todayUrgent, tomorrow, week, farMine, noDueMine, doneRecent, doneOld]
        live.forEach { $0.project = active }

        let summary = HomeSummary(
            projects: [active, risky, complete, archived],
            tasks: [overdueMine, today, todayUrgent, tomorrow, week, farMine, noDueMine, doneRecent, doneOld, hidden],
            now: referenceNow,
            calendar: utcCalendar
        )

        #expect(summary.activeProjects == 2)
        #expect(summary.projectsAtRisk == 1)
        #expect(summary.openTasks == 7)
        #expect(summary.openAssignedToMe == 5)
        #expect(summary.completedThisWeek == 1)
        #expect(summary.overdue == 1)
        #expect(summary.upcoming.map(\.title) == ["today urgent", "tomorrow", "far", "someday"])
        #expect(summary.overdueMine.map(\.title) == ["late"])
        #expect(summary.completedMine.map(\.title) == ["done recent"])
        #expect(summary.deadlines.map(\.title) == ["Today", "Tomorrow", "This week"])
        #expect(summary.deadlines[0].tasks.map(\.title) == ["today urgent", "today"])
        #expect(summary.deadlines[1].tasks.map(\.title) == ["tomorrow"])
        #expect(summary.deadlines[2].tasks.map(\.title) == ["week"])
    }

    @Test func cardCountsMatchTheListsTheyOpen() {
        let me = Member(name: "Tanjim Islam", email: "", isMe: true)
        let other = Member(name: "Sarah Chen", email: "")
        let live = Project(key: "WEB", name: "Web")
        let archived = Project(key: "OLD", name: "Old")
        archived.isArchived = true
        let recent = task("recent", .done, due: nil, mine: true, completedHoursAgo: 30, me: me, other: other)
        recent.updatedAt = referenceNow.addingTimeInterval(-20 * 86400)
        let editedOld = task(
            "edited old", .done, due: nil, mine: true, completedHoursAgo: 20 * 24, me: me, other: other)
        editedOld.updatedAt = referenceNow.addingTimeInterval(-3600)
        let late = task("late", .todo, due: -2, mine: true, me: me, other: other)
        [recent, editedOld, late].forEach { $0.project = live }
        let archivedDone = task("archived", .done, due: -2, mine: true, completedHoursAgo: 5, me: me, other: other)
        archivedDone.project = archived
        let orphanDone = task("orphan", .done, due: -2, mine: true, completedHoursAgo: 5, me: me, other: other)
        let tasks = [recent, editedOld, late, archivedDone, orphanDone]

        let summary = HomeSummary(projects: [live, archived], tasks: tasks, now: referenceNow, calendar: utcCalendar)
        let listed = { (filters: [TaskFilter]) in
            TaskViewQuery(filters: filters).apply(tasks.inLiveProjects(), now: referenceNow, calendar: utcCalendar)
        }
        let overdue = [TaskFilter(field: .due, values: [DueBucket.overdue.rawValue])]
        let open = [TaskFilter(field: .status, op: .isNot, values: [TaskStatus.done.rawValue])]

        #expect(listed(TaskFilter.completedThisWeek).map(\.title) == ["recent"])
        #expect(summary.completedThisWeek == listed(TaskFilter.completedThisWeek).count)
        #expect(summary.overdue == listed(overdue).count)
        #expect(summary.openTasks == listed(open).count)
    }
}
