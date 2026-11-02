import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct SavedViewActionsTests {
    private func makeProject(_ context: ModelContext) throws -> Project {
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        try context.save()
        return project
    }

    @Test func createTrimsAndDefaultsTheName() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        let actions = SavedViewActions(context: context)

        let trimmed = try actions.create(name: "  Urgent  ", layout: .list, filters: [], in: project)
        let blank = try actions.create(name: "   ", layout: .list, filters: [], in: project)

        #expect(trimmed.name == "Urgent")
        #expect(blank.name == "Untitled view")
    }

    @Test func createAppendsAfterTheLastView() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        let actions = SavedViewActions(context: context)

        let first = try actions.create(name: "A", layout: .list, filters: [], in: project)
        let second = try actions.create(name: "B", layout: .board, filters: [], in: project)

        #expect(second.sortOrder > first.sortOrder)
        #expect(SavedView.ordered(in: project).map(\.name) == ["A", "B"])
    }

    @Test func createStoresTheFiltersAndLayout() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        let filters = [TaskFilter(field: .priority, op: .isNot, values: ["low"])]

        let view = try SavedViewActions(context: context).create(
            name: "Mine", layout: .table, filters: filters, in: project)

        #expect(view.layout == .table)
        #expect(view.layoutRaw == "table")
        #expect(view.filters == filters)
        #expect(view.project === project)
    }

    @Test func renameIgnoresBlankNames() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        let actions = SavedViewActions(context: context)
        let view = try actions.create(name: "Old", layout: .list, filters: [], in: project)

        try actions.rename(view, to: "   ")
        #expect(view.name == "Old")

        try actions.rename(view, to: "  New  ")
        #expect(view.name == "New")
    }

    @Test func deleteRemovesTheView() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        let actions = SavedViewActions(context: context)
        let view = try actions.create(name: "Gone", layout: .list, filters: [], in: project)

        try actions.delete(view)

        #expect(try context.fetchCount(FetchDescriptor<SavedView>()) == 0)
        #expect(SavedView.ordered(in: project).isEmpty)
    }

    @Test func deletingTheProjectDeletesItsViews() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        try SavedViewActions(context: context).create(name: "A", layout: .list, filters: [], in: project)

        context.delete(project)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<SavedView>()) == 0)
    }

    @Test func corruptFiltersDataReadsAsEmpty() {
        let view = SavedView(name: "Broken", layout: .list)
        view.filtersData = Data("not json".utf8)

        #expect(view.filters.isEmpty)
    }

    @Test func resetDeletesSavedViews() throws {
        let context = try makeTestContext()
        let project = try makeProject(context)
        try SavedViewActions(context: context).create(name: "A", layout: .list, filters: [], in: project)

        try DataReset.deleteAll(in: context)

        #expect(try context.fetchCount(FetchDescriptor<SavedView>()) == 0)
    }
}
