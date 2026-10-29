import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct TableTests {
    private let context: ModelContext

    init() throws {
        context = try makeTestContext()
    }

    @Test func columnsFollowTheOriginalOrderAndWidths() {
        #expect(
            TableColumnID.allCases.map(\.title) == [
                "Task", "Status", "Priority", "Assignee", "Due date", "Start date", "Labels", "Dependencies",
                "Estimate", "Created", "Project",
            ])
        #expect(TableColumnID.allCases.map(\.defaultWidth) == [314, 132, 112, 156, 112, 112, 180, 150, 92, 112, 156])
        #expect(TableColumnID.minimumWidth == 64)
        #expect(TableColumnID.labels.sortField == nil)
        #expect(TableColumnID.deps.sortField == nil)
        #expect(TableColumnID.due.sortField == .due)
    }

    @Test func defaultVisibilityHidesTheSecondaryColumns() {
        #expect(
            TableViewState(inProject: true).visibleColumns == [
                .title, .status, .priority, .assignee, .due, .labels, .estimate,
            ])
        #expect(TableViewState(inProject: false).visibleColumns.last == .project)
    }

    @Test func theTaskColumnCannotBeHidden() {
        var state = TableViewState(inProject: true)
        state.setVisible(false, for: .title)
        state.setVisible(true, for: .created)
        state.setVisible(false, for: .status)
        #expect(state.visibleColumns.contains(.title))
        #expect(state.visibleColumns.contains(.created))
        #expect(!state.visibleColumns.contains(.status))
    }

    @Test func resetWidthsDropsOnlyTheColumnCustomization() throws {
        var state = TableViewState(inProject: true)
        state.columns = Data([1])
        state.sort = [TaskComparator(field: .due, order: .reverse)]
        state.resetWidths()
        #expect(state.columns == nil)
        #expect(state.hidden == TableColumnID.defaultHidden(inProject: true))
        let decoded = try JSONDecoder().decode(TableViewState.self, from: JSONEncoder().encode(state))
        #expect(decoded == state)
    }

    private func tasks() throws -> [TaskItem] {
        let project = Project(key: "WEB", name: "Website")
        let ann = Member(name: "Ann", email: "")
        let zed = Member(name: "Zed", email: "")
        context.insert(project)
        context.insert(ann)
        context.insert(zed)
        let specs: [(String, TaskStatus, TaskPriority, Date?, Date?, Member?, String?, Int)] = [
            ("beta", .review, .low, day(3), nil, zed, "2d", -1),
            ("Alpha", .backlog, .urgent, nil, day(1), nil, nil, -3),
            ("gamma", .todo, .medium, day(1), day(-2), ann, "1h", -2),
        ]
        return specs.enumerated().map { index, spec in
            let task = TaskItem(number: index + 1, title: spec.0)
            context.insert(task)
            task.project = project
            task.status = spec.1
            task.priority = spec.2
            task.due = spec.3
            task.start = spec.4
            task.assignee = spec.5
            task.estimate = spec.6
            task.createdAt = day(spec.7)
            task.sortOrder = Double(index)
            return task
        }
    }

    @Test(arguments: [
        (TaskSortField.manual, ["beta", "Alpha", "gamma"]),
        (.title, ["Alpha", "beta", "gamma"]),
        (.status, ["Alpha", "gamma", "beta"]),
        (.priority, ["Alpha", "gamma", "beta"]),
        (.assignee, ["gamma", "beta", "Alpha"]),
        (.due, ["gamma", "beta", "Alpha"]),
        (.start, ["gamma", "Alpha", "beta"]),
        (.estimate, ["gamma", "beta", "Alpha"]),
        (.created, ["beta", "gamma", "Alpha"]),
    ])
    func sortsAscendingLikeTheOriginal(field: TaskSortField, titles: [String]) throws {
        #expect(TableSort.sorted(try tasks(), by: [TaskComparator(field: field)]).map(\.title) == titles)
    }

    @Test func projectSortOrdersByProjectNameWithManualTieBreak() throws {
        let all = try tasks()
        let apps = Project(key: "APP", name: "Apps")
        context.insert(apps)
        all[1].project = apps
        let sorted = TableSort.sorted(all.reversed(), by: [TaskComparator(field: .project)])
        #expect(sorted.map(\.title) == ["Alpha", "beta", "gamma"])
        let descending = TableSort.sorted(all.reversed(), by: [TaskComparator(field: .project, order: .reverse)])
        #expect(descending.map(\.title) == ["beta", "gamma", "Alpha"])
    }

    @Test func reverseInvertsTheWholeOrderIncludingEmpties() throws {
        let sorted = TableSort.sorted(try tasks(), by: [TaskComparator(field: .due, order: .reverse)])
        #expect(sorted.map(\.title) == ["Alpha", "beta", "gamma"])
    }

    @Test func tiesFallBackToTheManualOrder() throws {
        let all = try tasks()
        all.forEach { $0.priority = .high }
        #expect(
            TableSort.sorted(all.reversed(), by: [TaskComparator(field: .priority)]).map(\.title)
                == ["beta", "Alpha", "gamma"])
    }

    @Test func blankEstimatesSortLikeMissingOnes() throws {
        let all = try tasks()
        all[0].estimate = ""
        all[1].estimate = "  "
        let sorted = TableSort.sorted(all.reversed(), by: [TaskComparator(field: .estimate)])
        #expect(sorted.map(\.title) == ["gamma", "beta", "Alpha"])
    }

    @Test func equalManualOrderFallsBackToNumberThenId() throws {
        let all = try tasks()
        all.forEach { $0.sortOrder = 1 }
        let expected = all.sorted { $0.number < $1.number }.map(\.title)
        #expect(TableSort.sorted(all.reversed(), by: []).map(\.title) == expected)
        all[1].number = all[0].number
        let byId = all.sorted { $0.number == $1.number ? $0.id.uuidString < $1.id.uuidString : $0.number < $1.number }
        #expect(TableSort.sorted(all.reversed(), by: []).map(\.title) == byId.map(\.title))
    }

    @Test func decodingToleratesMissingKeysAndUnknownColumns() throws {
        let json = Data(#"{"hidden":["created","retired","deps"]}"#.utf8)
        let state = try JSONDecoder().decode(TableViewState.self, from: json)
        #expect(state.hidden == [.created, .deps])
        #expect(state.sort.isEmpty)
        #expect(state.columns == nil)
        let empty = try JSONDecoder().decode(TableViewState.self, from: Data("{}".utf8))
        #expect(empty.hidden == TableColumnID.defaultHidden(inProject: false))
    }

    @Test func hiddenColumnsEncodeInCaseOrder() throws {
        var state = TableViewState(inProject: true)
        state.hidden = [.project, .start, .created]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let text = try #require(String(bytes: try encoder.encode(state), encoding: .utf8))
        #expect(text.contains(#""hidden":["start","created","project"]"#))
    }
}
