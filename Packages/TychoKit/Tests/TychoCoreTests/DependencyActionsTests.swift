import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct DependencyActionsTests {
    private func setUp() throws -> (ModelContext, Project, [TaskItem], DependencyActions) {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        let actions = TaskActions(context: context, now: { referenceNow })
        let tasks = try ["Audit", "Wireframes", "Handoff"].map {
            try actions.create(TaskDraft(title: $0), in: project)
        }
        return (context, project, tasks, DependencyActions(context: context, now: { referenceNow }))
    }

    @Test func togglesADependencyOnAndOff() throws {
        let (_, _, tasks, actions) = try setUp()
        try actions.toggle(tasks[1], for: tasks[2])
        try actions.toggle(tasks[0], for: tasks[2])
        #expect(tasks[2].orderedBlockedBy.map(\.title) == ["Audit", "Wireframes"])
        #expect(tasks[2].isBlocked(by: tasks[1]))
        #expect(tasks[2].updatedAt == referenceNow)

        try actions.toggle(tasks[1], for: tasks[2])
        #expect(tasks[2].orderedBlockedBy.map(\.title) == ["Audit"])
    }

    @Test func rejectsTheTaskItself() throws {
        let (_, _, tasks, actions) = try setUp()
        #expect(throws: ValidationError.dependencyOnSelf) { try actions.toggle(tasks[0], for: tasks[0]) }
        #expect(tasks[0].blockedBy?.isEmpty == true)
    }

    @Test func rejectsATaskFromAnotherProject() throws {
        let (context, _, tasks, actions) = try setUp()
        let other = Project(key: "MOB", name: "Mobile")
        context.insert(other)
        let foreign = try TaskActions(context: context).create(TaskDraft(title: "Build"), in: other)
        #expect(throws: ValidationError.dependencyAcrossProjects) { try actions.toggle(foreign, for: tasks[0]) }
    }

    @Test func rejectsADirectCycle() throws {
        let (_, _, tasks, actions) = try setUp()
        try actions.toggle(tasks[0], for: tasks[1])
        #expect(throws: ValidationError.dependencyCycle) { try actions.toggle(tasks[1], for: tasks[0]) }
        #expect(tasks[0].blockedBy?.isEmpty == true)
    }

    @Test func candidatesAreTheSameProjectInKeyOrderWithoutTheTask() throws {
        let (context, _, tasks, _) = try setUp()
        let other = Project(key: "MOB", name: "Mobile")
        context.insert(other)
        try TaskActions(context: context).create(TaskDraft(title: "Build"), in: other)

        #expect(DependencyActions.candidates(for: tasks[1]).map(\.title) == ["Audit", "Handoff"])
        #expect(DependencyActions.candidates(for: tasks[1], matching: "hand").map(\.title) == ["Handoff"])
        #expect(DependencyActions.candidates(for: tasks[1], matching: "WEB-1").map(\.title) == ["Audit"])
    }
}
