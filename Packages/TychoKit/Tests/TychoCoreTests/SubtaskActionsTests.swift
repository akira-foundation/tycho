import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct SubtaskActionsTests {
    private func setUp() throws -> (TaskItem, SubtaskActions) {
        let context = try makeTestContext()
        let task = TaskItem(number: 1, title: "Wireframes")
        context.insert(task)
        return (task, SubtaskActions(context: context, now: { referenceNow }))
    }

    @Test func addsInOrderAndTouchesTheTask() throws {
        let (task, actions) = try setUp()
        try actions.add("Desktop", to: task)
        try actions.add(" Mobile ", to: task)
        #expect(task.orderedSubtasks.map(\.title) == ["Desktop", "Mobile"])
        #expect(task.updatedAt == referenceNow)
    }

    @Test func rejectsBlankTitles() throws {
        let (task, actions) = try setUp()
        #expect(throws: ValidationError.emptyTitle) { try actions.add("   ", to: task) }
        let subtask = try actions.add("Desktop", to: task)
        #expect(throws: ValidationError.emptyTitle) { try actions.rename(subtask, to: "") }
        #expect(subtask.title == "Desktop")
    }

    @Test func togglesMovesAndDeletes() throws {
        let (task, actions) = try setUp()
        let a = try actions.add("A", to: task)
        try actions.add("B", to: task)
        let c = try actions.add("C", to: task)
        try actions.toggle(a)
        #expect(a.isDone)
        try actions.move(c, to: 0)
        #expect(task.orderedSubtasks.map(\.title) == ["C", "A", "B"])
        try actions.delete(a)
        #expect(task.orderedSubtasks.map(\.title) == ["C", "B"])
    }
}
