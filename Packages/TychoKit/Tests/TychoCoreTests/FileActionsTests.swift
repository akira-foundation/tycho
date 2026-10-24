import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct FileActionsTests {
    private func setUp() throws -> (ModelContext, Project, TaskItem, Member, FileActions) {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        let me = Member(name: "Tanjim Islam", email: "", isMe: true)
        context.insert(project)
        context.insert(me)
        let task = try TaskActions(context: context).create(TaskDraft(title: "Wireframes"), in: project)
        return (context, project, task, me, FileActions(context: context, now: { referenceNow }))
    }

    @Test func addDerivesKindAndSizeAndStoresTheData() throws {
        let (_, project, task, me, actions) = try setUp()
        let file = try actions.add(name: " Hero.PNG ", data: Data([1, 2, 3]), to: project, task: task, by: me)
        #expect(file.name == "Hero.PNG")
        #expect(file.kind == .img)
        #expect(file.byteCount == 3)
        #expect(file.hasData)
        #expect(file.data == Data([1, 2, 3]))
        #expect(file.uploadedAt == referenceNow)
        #expect(file.uploadedBy === me)
        #expect(task.orderedAttachments.map(\.name) == ["Hero.PNG"])
        #expect(project.files?.count == 1)
    }

    @Test func addRejectsMoreThan250MegabytesAndBlankNames() throws {
        let (context, project, _, me, actions) = try setUp()
        #expect(FileActions.maxByteCount == 262_144_000)
        #expect(throws: ValidationError.fileTooLarge) {
            try actions.add(
                name: "huge.zip", data: Data(count: FileActions.maxByteCount + 1), to: project, task: nil, by: me)
        }
        #expect(throws: ValidationError.emptyName) {
            try actions.add(name: "  ", data: Data([1]), to: project, task: nil, by: me)
        }
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 0)
    }

    @Test func renameRederivesTheKindAndRejectsBlank() throws {
        let (_, project, _, me, actions) = try setUp()
        let file = try actions.add(name: "notes.txt", data: Data([1]), to: project, task: nil, by: me)
        try actions.rename(file, to: "notes.pdf")
        #expect(file.kind == .pdf)
        #expect(throws: ValidationError.emptyName) { try actions.rename(file, to: " ") }
        #expect(file.name == "notes.pdf")
    }

    @Test func duplicateCopiesUnderANewNameAndUploader() throws {
        let (context, project, task, me, _) = try setUp()
        let sarah = Member(name: "Sarah Chen", email: "")
        context.insert(sarah)
        let original = try FileActions(context: context, now: { day(-2) })
            .add(name: "brief.pdf", data: Data([7]), to: project, task: task, by: sarah)

        let copy = try FileActions(context: context, now: { referenceNow }).duplicate(original, by: me)

        #expect(copy.name == "brief copy.pdf")
        #expect(copy !== original)
        #expect(copy.uploadedAt == referenceNow)
        #expect(copy.uploadedBy === me)
        #expect(copy.task === task)
        #expect(copy.data == Data([7]))
        #expect(copy.hasData)
        #expect(copy.byteCount == 1)
        #expect(project.files?.count == 2)
    }

    @Test func duplicatingASeedFileKeepsItWithoutData() throws {
        let (context, project, _, me, actions) = try setUp()
        let seeded = FileRecord(name: "sitemap-v2.pdf", byteCount: 552_960, uploadedAt: day(-8))
        context.insert(seeded)
        seeded.project = project
        let copy = try actions.duplicate(seeded, by: me)
        #expect(copy.name == "sitemap-v2 copy.pdf")
        #expect(!copy.hasData)
        #expect(copy.sizeText == "540 KB")
    }

    @Test func deleteRemovesTheFileFromTheTask() throws {
        let (context, project, task, me, actions) = try setUp()
        let file = try actions.add(name: "brief.pdf", data: Data([1]), to: project, task: task, by: me)
        try actions.delete(file)
        #expect(task.orderedAttachments.isEmpty)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 0)
    }
}
