import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct TaskActionsTests {
    private func setUp() throws -> (ModelContext, Project, TaskActions) {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        project.nextTaskNumber = 103
        context.insert(project)
        return (context, project, TaskActions(context: context, now: { referenceNow }))
    }

    @Test func createNumbersSequentiallyAndAppendsToTheStatusGroup() throws {
        let (_, project, actions) = try setUp()
        let first = try actions.create(TaskDraft(title: "Audit"), in: project)
        let second = try actions.create(TaskDraft(title: "  Wireframes  "), in: project)

        #expect(first.key == "WEB-103")
        #expect(second.key == "WEB-104")
        #expect(second.title == "Wireframes")
        #expect(project.nextTaskNumber == 105)
        #expect(second.sortOrder > first.sortOrder)
        #expect(second.createdAt == referenceNow)
        #expect(second.completedAt == nil)
    }

    @Test(arguments: ["", "   ", "\t\n"])
    func rejectsABlankTitle(title: String) throws {
        let (_, project, actions) = try setUp()
        #expect(throws: ValidationError.emptyTitle) {
            try actions.create(TaskDraft(title: title), in: project)
        }
        #expect(project.nextTaskNumber == 103)
    }

    @Test func renameRejectsBlankAndKeepsTheOldTitle() throws {
        let (_, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        #expect(throws: ValidationError.emptyTitle) { try actions.rename(task, to: "  ") }
        #expect(task.title == "Audit")
    }

    @Test func creatingADoneTaskStampsCompletion() throws {
        let (_, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Shipped", status: .done), in: project)
        #expect(task.completedAt == referenceNow)
    }

    @Test func setStatusStampsAndClearsCompletion() throws {
        let (_, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        try actions.setStatus(task, .done)
        #expect(task.completedAt == referenceNow)
        try actions.setStatus(task, .review)
        #expect(task.completedAt == nil)
        #expect(task.status == .review)
    }

    @Test func toggleDoneReturnsToTodo() throws {
        let (_, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit", status: .progress), in: project)
        try actions.toggleDone(task)
        #expect(task.status == .done)
        try actions.toggleDone(task)
        #expect(task.status == .todo)
    }

    @Test func moveChangesStatusAndPlacesBetweenSiblings() throws {
        let (_, project, actions) = try setUp()
        let a = try actions.create(TaskDraft(title: "A", status: .review), in: project)
        let b = try actions.create(TaskDraft(title: "B", status: .review), in: project)
        let moved = try actions.create(TaskDraft(title: "M", status: .todo), in: project)

        let siblings = TaskActions.siblings(of: .review, in: project, excluding: moved)
        try actions.move(moved, to: .review, at: 1, among: siblings)

        let review = TaskActions.siblings(of: .review, in: project, excluding: nil)
        #expect(review.map(\.title) == ["A", "M", "B"])
        #expect(moved.status == .review)
        #expect(a.sortOrder < moved.sortOrder && moved.sortOrder < b.sortOrder)
    }

    @Test func editBumpsUpdatedAt() throws {
        let (context, project, _) = try setUp()
        var clock = referenceNow
        let actions = TaskActions(context: context, now: { clock })
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        clock = referenceNow.addingTimeInterval(120)
        try actions.edit(task) { $0.priority = .urgent }
        #expect(task.priority == .urgent)
        #expect(task.updatedAt == clock)
    }

    @Test func deleteRemovesTheTask() throws {
        let (context, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        try actions.delete(task)
        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 0)
    }

    @Test func aTaskIsStoredUntilABatchDeleteRemovesIt() throws {
        let (context, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        try context.save()
        #expect(try actions.isStored(task))

        try DataReset.deleteAll(in: context)

        #expect(try !actions.isStored(task))
    }

    @Test func aTaskDeletedThroughTheActionsIsNotStored() throws {
        let (context, project, actions) = try setUp()
        let task = try actions.create(TaskDraft(title: "Audit"), in: project)
        try context.save()

        try actions.delete(task)

        #expect(try !actions.isStored(task))
    }
}
