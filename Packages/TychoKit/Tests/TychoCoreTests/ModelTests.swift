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

    @Test func deletingAProjectCascadesToMilestonesEventsAndFiles() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Web")
        let milestone = Milestone(name: "Launch", date: day(3))
        let event = CalendarEvent(title: "Review", date: day(1), time: "10:00")
        let file = FileRecord(name: "brief.pdf", byteCount: 10, uploadedAt: referenceNow)
        context.insert(project)
        context.insert(milestone)
        context.insert(event)
        context.insert(file)
        milestone.project = project
        event.project = project
        file.project = project
        try context.save()

        context.delete(project)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Milestone>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CalendarEvent>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 0)
    }

    @Test func dependenciesKeepBothSidesInSync() throws {
        let context = try makeTestContext()
        let blocker = TaskItem(number: 1, title: "Wireframes")
        let blocked = TaskItem(number: 2, title: "Handoff")
        context.insert(blocker)
        context.insert(blocked)
        blocked.blockedBy = [blocker]
        try context.save()

        #expect(blocker.blocking?.contains { $0 === blocked } == true)
        #expect(blocked.orderedBlockedBy.map(\.title) == ["Wireframes"])
    }

    @Test func deletingATaskKeepsItsFilesAndFreesItsDependents() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Web")
        let blocker = TaskItem(number: 1, title: "Wireframes")
        let blocked = TaskItem(number: 2, title: "Handoff")
        let file = FileRecord(name: "wireframes.fig", byteCount: 10, uploadedAt: referenceNow)
        context.insert(project)
        context.insert(blocker)
        context.insert(blocked)
        context.insert(file)
        blocker.project = project
        blocked.project = project
        blocked.blockedBy = [blocker]
        file.project = project
        file.task = blocker
        try context.save()

        context.delete(blocker)
        try context.save()

        #expect(blocked.blockedBy?.isEmpty == true)
        #expect(file.task == nil)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 1)
    }

    @Test func deletingAMemberKeepsTheirFiles() throws {
        let context = try makeTestContext()
        let member = Member(name: "Sarah Chen", email: "sarah@example.com")
        let file = FileRecord(name: "brief.pdf", byteCount: 10, uploadedAt: referenceNow)
        context.insert(member)
        context.insert(file)
        file.uploadedBy = member
        try context.save()

        context.delete(member)
        try context.save()

        #expect(file.uploadedBy == nil)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 1)
    }

    @Test func fileRecordsDeriveKindSizeAndExtension() {
        let file = FileRecord(name: "hero.PNG", byteCount: 2_202_010, uploadedAt: referenceNow)
        #expect(file.kind == .img)
        #expect(file.typeRaw == "img")
        #expect(file.sizeText == "2.1 MB")
        #expect(file.fileExtension == "png")
        #expect(!file.hasData)
        file.typeRaw = "bogus"
        #expect(file.kind == .other)
    }

    @Test func attachmentsAreNewestFirst() throws {
        let context = try makeTestContext()
        let task = TaskItem(number: 1, title: "Wireframes")
        let old = FileRecord(name: "old.pdf", byteCount: 1, uploadedAt: day(-3))
        let new = FileRecord(name: "new.pdf", byteCount: 1, uploadedAt: day(-1))
        context.insert(task)
        context.insert(old)
        context.insert(new)
        old.task = task
        new.task = task
        try context.save()

        #expect(task.orderedAttachments.map(\.name) == ["new.pdf", "old.pdf"])
    }
}
