import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskMoveHandlerTests {
    private func setUp() throws -> (ModelContext, Project, [TaskItem]) {
        let context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        let project = Project(key: "WEB", name: "Web")
        context.insert(project)
        let actions = TaskActions(context: context)
        let tasks = try ["A", "B", "C"].map { try actions.create(TaskDraft(title: $0, status: .todo), in: project) }
        return (context, project, tasks)
    }

    @Test func droppingOnATaskInsertsBeforeIt() throws {
        let (context, project, tasks) = try setUp()
        let handled = try TaskMoveHandler(context: context).drop(
            [tasks[2].id], into: .todo, before: tasks[0], in: project.tasks ?? [])
        #expect(handled)
        #expect(TaskActions.siblings(of: .todo, in: project, excluding: nil).map(\.title) == ["C", "A", "B"])
    }

    @Test func droppingOnAGroupAppendsAndChangesStatus() throws {
        let (context, project, tasks) = try setUp()
        _ = try TaskMoveHandler(context: context).drop([tasks[0].id], into: .done, before: nil, in: project.tasks ?? [])
        #expect(tasks[0].status == .done)
        #expect(tasks[0].completedAt != nil)
        #expect(TaskActions.siblings(of: .todo, in: project, excluding: nil).map(\.title) == ["B", "C"])
    }

    @Test func droppingOnItselfIsANoOp() throws {
        let (context, project, tasks) = try setUp()
        let before = tasks.map(\.sortOrder)
        let handled = try TaskMoveHandler(context: context).drop(
            [tasks[1].id], into: .todo, before: tasks[1], in: project.tasks ?? [])
        #expect(!handled)
        #expect(tasks.map(\.sortOrder) == before)
    }

    @Test func unknownIdsAreIgnored() throws {
        let (context, project, _) = try setUp()
        #expect(
            try !TaskMoveHandler(context: context).drop([UUID()], into: .todo, before: nil, in: project.tasks ?? []))
    }
}
