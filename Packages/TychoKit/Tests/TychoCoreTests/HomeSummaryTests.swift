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
}
