import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct ModelTests {
    @Test func typedAccessorsRoundTripThroughRawStorage() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website Redesign")
        project.status = .risk
        project.color = .teal
        let task = TaskItem(number: 103, title: "Audit")
        task.status = .review
        task.priority = .urgent
        task.labels = [.design, .qa]
        task.project = project
        context.insert(project)
        context.insert(task)
        try context.save()

        #expect(project.statusRaw == "risk")
        #expect(project.colorRaw == "teal")
        #expect(task.statusRaw == "review")
        #expect(task.priorityRaw == "urgent")
        #expect(Set(task.labelsRaw) == ["design", "qa"])
        #expect(task.labels == [.design, .qa])
        #expect(task.key == "WEB-103")
    }

    @Test func unknownRawValuesFallBackToDefaults() {
        let task = TaskItem(number: 1, title: "x")
        task.statusRaw = "archived"
        task.priorityRaw = "bogus"
        task.labelsRaw = ["design", "nope"]
        #expect(task.status == .todo)
        #expect(task.priority == .noPriority)
        #expect(task.labels == [.design])
    }

    @Test func deletingAProjectCascadesToTasksAndSubtasks() throws {
        let context = try makeTestContext()
        let project = Project(key: "MOB", name: "Mobile")
        let task = TaskItem(number: 1, title: "Build")
        let subtask = Subtask(title: "Step")
        context.insert(project)
        task.project = project
        subtask.task = task
        try context.save()

        context.delete(project)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Subtask>()) == 0)
    }

    @Test func deletingAMemberNullifiesAssigneeAndLead() throws {
        let context = try makeTestContext()
        let member = Member(name: "Sarah Chen", email: "sarah@example.com")
        let project = Project(key: "WEB", name: "Web")
        let task = TaskItem(number: 1, title: "Wireframes")
        context.insert(member)
        context.insert(project)
        project.lead = member
        task.project = project
        task.assignee = member
        try context.save()

        context.delete(member)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<Project>()) == 1)
        #expect(task.assignee == nil)
        #expect(project.lead == nil)
    }
}
