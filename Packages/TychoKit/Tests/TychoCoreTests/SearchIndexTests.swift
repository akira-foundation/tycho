import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct SearchIndexTests {
    @discardableResult
    private func makeProject(
        _ context: ModelContext, key: String, name: String, summary: String = "",
        sortOrder: Double = 0, archived: Bool = false
    ) -> Project {
        let project = Project(key: key, name: name)
        project.summary = summary
        project.sortOrder = sortOrder
        project.isArchived = archived
        context.insert(project)
        return project
    }

    @discardableResult
    private func makeTask(
        _ context: ModelContext, _ number: Int, _ title: String, notes: String = "",
        sortOrder: Double = 0, in project: Project
    ) -> TaskItem {
        let task = TaskItem(number: number, title: title)
        task.notes = notes
        task.sortOrder = sortOrder
        task.project = project
        context.insert(task)
        return task
    }

    @discardableResult
    private func makeFile(_ context: ModelContext, _ name: String, in project: Project) -> FileRecord {
        let file = FileRecord(name: name, byteCount: 10, uploadedAt: referenceNow)
        file.project = project
        context.insert(file)
        return file
    }

    @Test func emptyQueryReturnsNothing() throws {
        let context = try makeTestContext()
        let project = makeProject(context, key: "WEB", name: "Website")
        makeTask(context, 1, "Landing page", in: project)

        let blank = try SearchIndex.search("   ", in: context)
        let empty = try SearchIndex.search("", in: context)

        #expect(blank.isEmpty)
        #expect(empty.isEmpty)
    }

    @Test func tasksMatchTitleKeyAndNotes() throws {
        let context = try makeTestContext()
        let project = makeProject(context, key: "WEB", name: "Website")
        makeTask(context, 1, "Landing PAGE", in: project)
        makeTask(context, 2, "Unrelated", notes: "Fix the landing copy", sortOrder: 1, in: project)
        makeTask(context, 7, "Other", sortOrder: 2, in: project)

        let byTitle = try SearchIndex.search("  landing ", in: context).tasks.map(\.number)
        let byKey = try SearchIndex.search("web-7", in: context).tasks.map(\.number)

        #expect(byTitle == [1, 2])
        #expect(byKey == [7])
    }

    @Test func projectsMatchNameAndSummary() throws {
        let context = try makeTestContext()
        makeProject(context, key: "B", name: "Billing", summary: "Invoices", sortOrder: 2)
        makeProject(context, key: "A", name: "Marketing site", summary: "billing banner", sortOrder: 1)
        makeProject(context, key: "C", name: "Other", sortOrder: 3)

        let results = try SearchIndex.search("BILLING", in: context)

        #expect(results.projects.map(\.key) == ["A", "B"])
    }

    @Test func filesMatchName() throws {
        let context = try makeTestContext()
        let first = makeProject(context, key: "A", name: "Alpha", sortOrder: 1)
        let second = makeProject(context, key: "B", name: "Beta", sortOrder: 2)
        makeFile(context, "spec-b.pdf", in: second)
        makeFile(context, "spec-z.pdf", in: first)
        makeFile(context, "spec-a.pdf", in: first)
        makeFile(context, "logo.png", in: first)

        let results = try SearchIndex.search("SPEC", in: context)

        #expect(results.files.map(\.name) == ["spec-a.pdf", "spec-z.pdf", "spec-b.pdf"])
    }

    @Test func archivedProjectsAreExcludedWithTheirTasksAndFiles() throws {
        let context = try makeTestContext()
        let live = makeProject(context, key: "LIV", name: "Live shared")
        let archived = makeProject(context, key: "OLD", name: "Archived shared", archived: true)
        makeTask(context, 1, "shared live", in: live)
        makeTask(context, 1, "shared archived", in: archived)
        makeFile(context, "shared-live.txt", in: live)
        makeFile(context, "shared-archived.txt", in: archived)

        let results = try SearchIndex.search("shared", in: context)

        #expect(results.projects.map(\.key) == ["LIV"])
        #expect(results.tasks.map(\.title) == ["shared live"])
        #expect(results.files.map(\.name) == ["shared-live.txt"])
    }

    @Test func tasksAreCappedAtThirty() throws {
        let context = try makeTestContext()
        let project = makeProject(context, key: "WEB", name: "Website")
        for number in 1...40 {
            makeTask(context, number, "item \(number)", sortOrder: Double(number), in: project)
        }

        let results = try SearchIndex.search("item", in: context)

        #expect(results.tasks.count == 30)
        #expect(results.tasks.first?.number == 1)
    }

    @Test func limitCapsEveryGroup() throws {
        let context = try makeTestContext()
        for index in 1...5 {
            let project = makeProject(context, key: "P\(index)", name: "match \(index)", sortOrder: Double(index))
            makeTask(context, 1, "match task", in: project)
            makeFile(context, "match-\(index).txt", in: project)
        }

        let results = try SearchIndex.search("match", in: context, limit: 2)

        #expect(results.projects.count == 2)
        #expect(results.tasks.count == 2)
        #expect(results.files.count == 2)
        #expect(results.projects.map(\.key) == ["P1", "P2"])
    }
}
