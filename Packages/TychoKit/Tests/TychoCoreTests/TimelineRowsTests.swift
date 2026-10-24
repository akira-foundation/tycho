import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct TimelineRowsTests {
    private let context: ModelContext

    init() throws {
        context = try makeTestContext()
    }

    private struct Fixture {
        let project: Project
        let members: [Member]
        let tasks: [TaskItem]
    }

    private func fixture() throws -> Fixture {
        let project = Project(key: "WEB", name: "Website")
        let john = Member(name: "John Carter", email: "")
        let sarah = Member(name: "Sarah Chen", email: "")
        context.insert(project)
        context.insert(john)
        context.insert(sarah)
        let specs: [(String, TaskStatus, Date?, Date?, Member?)] = [
            ("Later", .todo, day(2), day(5), sarah),
            ("Sooner", .todo, nil, day(3), nil),
            ("Shipped", .done, day(-1), day(1), john),
            ("Undated", .review, nil, nil, john),
        ]
        let tasks = specs.enumerated().map { index, spec in
            let task = TaskItem(number: index + 1, title: spec.0)
            context.insert(task)
            task.project = project
            task.status = spec.1
            task.start = spec.2
            task.due = spec.3
            task.assignee = spec.4
            return task
        }
        return Fixture(project: project, members: [john, sarah], tasks: tasks)
    }

    private func describe(_ rows: [TimelineRow]) -> [String] {
        rows.map { row in
            switch row {
            case .milestones(let count): "milestones \(count)"
            case .group(let group): "\(group.title) \(group.count)"
            case .task(let task): task.title
            }
        }
    }

    private func rows(_ grouping: TimelineGrouping, milestones: Int = 0) throws -> [TimelineRow] {
        let data = try fixture()
        return TimelineRows.build(
            tasks: data.tasks, grouping: grouping, milestoneCount: milestones, members: data.members,
            projects: [data.project])
    }

    @Test func statusGroupsHideEmptyOnesAndSortByStartOrDue() throws {
        #expect(describe(try rows(.status)) == ["To Do 2", "Later", "Sooner", "Done 1", "Shipped"])
    }

    @Test func milestonesComeFirst() throws {
        #expect(describe(try rows(.status, milestones: 2)).first == "milestones 2")
    }

    @Test func noGroupingHasNoHeaders() throws {
        #expect(describe(try rows(.none)) == ["Shipped", "Later", "Sooner"])
    }

    @Test func assigneeGroupsPutUnassignedLast() throws {
        #expect(
            describe(try rows(.assignee)) == [
                "John Carter 1", "Shipped", "Sarah Chen 1", "Later", "Unassigned 1", "Sooner",
            ])
    }

    @Test func projectGroupsUseTheProjectName() throws {
        #expect(describe(try rows(.project)).first == "Website 3")
    }

    @Test func rowCentersAreThirtySixApart() throws {
        let built = try rows(.status)
        let centers = TimelineRows.centers(of: built)
        guard case .task(let later) = built[1], case .task(let sooner) = built[2] else {
            Issue.record("expected task rows")
            return
        }
        #expect(centers[later.id] == 54)
        #expect(centers[sooner.id] == 90)
        #expect(built[0].isHeader)
        #expect(!built[1].isHeader)
    }
}
