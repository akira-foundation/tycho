import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct SavedViewFlowTests {
    private let container: ModelContainer
    private let context: ModelContext
    private let defaults: UserDefaults
    private let router: Router
    private let toast = ToastCenter()
    private let project = Project(key: "WEB", name: "Website Redesign")

    init() throws {
        container = try TychoSchema.makeContainer(inMemory: true)
        context = ModelContext(container)
        let suite = "SavedViewFlowTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        router = Router(defaults: defaults)
        context.insert(project)
        try context.save()
    }

    private var flow: SavedViewFlow {
        SavedViewFlow(context: context, router: router, toast: toast, defaults: defaults)
    }

    private func makeView(_ name: String, filters: [TaskFilter] = []) throws -> SavedView {
        try SavedViewActions(context: context).create(name: name, layout: .table, filters: filters, in: project)
    }

    @Test func savingCopiesTheBaseProjectFiltersEvenFromASavedView() throws {
        let base = TaskViewModel.project(project.id, defaults: defaults)
        base.addFilter(.status)
        base.updateFilter(at: 0) { $0.values = ["done"] }
        let open = try makeView("High priority", filters: [TaskFilter(field: .priority, values: ["high"])])
        let openModel = TaskViewModel.savedView(open.id, defaults: defaults)
        openModel.seedFiltersIfUnsaved(open.filters)
        openModel.addFilter(.assignee)
        router.openProject(project.id, tab: .savedView(open.id))

        flow.save(name: "Done work", layout: .board, in: project)

        let saved = try #require(SavedView.ordered(in: project).last)
        #expect(saved.name == "Done work")
        #expect(saved.layout == .board)
        #expect(saved.filters == [TaskFilter(field: .status, values: ["done"])])
        #expect(router.route == .project(project.id, .savedView(saved.id)))
        #expect(toast.message == "Saved view “Done work”")
    }

    @Test func openingSeedsTheViewStateOnce() throws {
        let stored = [TaskFilter(field: .priority, values: ["urgent", "high"])]
        let view = try makeView("High priority", filters: stored)

        let first = TaskViewModel.savedView(view.id, defaults: defaults)
        #expect(first.state.filters.isEmpty)
        first.seedFiltersIfUnsaved(view.filters)
        #expect(first.state.filters == stored)
        first.removeFilter(at: 0)

        let reopened = TaskViewModel.savedView(view.id, defaults: defaults)
        reopened.seedFiltersIfUnsaved(view.filters)
        #expect(reopened.state.filters.isEmpty)
        #expect(view.filters == stored)
    }

    @Test func deletingTheOpenViewGoesToList() throws {
        let open = try makeView("High priority")
        let other = try makeView("Mine")
        router.openProject(project.id, tab: .savedView(open.id))

        flow.delete(open)

        #expect(router.route == .project(project.id, .list))
        #expect(toast.message == "Deleted view “High priority”")
        #expect(SavedView.ordered(in: project).map(\.id) == [other.id])
    }

    @Test func deletingAnotherViewKeepsTheRoute() throws {
        let open = try makeView("High priority")
        let other = try makeView("Mine")
        router.openProject(project.id, tab: .savedView(open.id))

        flow.delete(other)

        #expect(router.route == .project(project.id, .savedView(open.id)))
        #expect(toast.message == "Deleted view “Mine”")
    }

    @Test func renamingIgnoresABlankName() throws {
        let view = try makeView("High priority")

        flow.rename(view, to: "   ")
        #expect(view.name == "High priority")

        flow.rename(view, to: "Hot")
        #expect(view.name == "Hot")
    }

    @Test func theSaveSheetCountsTheFiltersToBeSaved() {
        #expect(SaveViewSheet.filterSummary(count: 1) == "1 filter will be saved with this view.")
        #expect(SaveViewSheet.filterSummary(count: 3) == "3 filters will be saved with this view.")
        #expect(SaveViewSheet.filterSummary(count: 0).hasPrefix("No filters are active."))
    }

    @Test func thePickerSelectsOnlyBuiltInTabs() {
        #expect(ProjectTabTarget.pickerSelection(for: .table) == .table)
        #expect(ProjectTabTarget.pickerSelection(for: .savedView(UUID())) == nil)
    }

    @Test func aMissingSavedViewRouteShowsTheBoard() {
        let missing = ProjectTabTarget(tab: .savedView(UUID()), in: project)

        #expect(missing.layout == .board)
        #expect(missing.savedView == nil)
        #expect(missing.stateKey == TaskViewStates.projectKey(project.id))
        #expect(missing.title == "Website Redesign")
    }

    @Test func aSavedViewTabShowsItsLayoutAndOwnState() throws {
        let view = try makeView("High priority")
        let target = ProjectTabTarget(tab: .savedView(view.id), in: project)

        #expect(target.layout == .table)
        #expect(target.savedView?.id == view.id)
        #expect(target.stateKey == TaskViewStates.savedViewKey(view.id))
        #expect(target.title == "Saved view · Website Redesign")
    }

    @Test func builtInTabsShareTheProjectState() {
        let target = ProjectTabTarget(tab: .list, in: project)

        #expect(target.layout == .list)
        #expect(target.stateKey == TaskViewStates.projectKey(project.id))
        #expect(target.title == "Website Redesign")
    }

    @Test func writesDropEntriesOfDeletedSavedViews() throws {
        let kept = try makeView("Kept")
        let gone = try makeView("Gone")
        TaskViewModel.savedView(gone.id, defaults: defaults).setQuery("gone")
        let model = TaskViewModel.savedView(kept.id, defaults: defaults)
        model.liveSavedViewIDs = [kept.id]

        model.setQuery("kept")

        let data = try #require(defaults.data(forKey: TaskViewStates.storageKey))
        #expect(!TaskViewStates.contains(TaskViewStates.savedViewKey(gone.id), in: data))
        #expect(TaskViewStates.contains(TaskViewStates.savedViewKey(kept.id), in: data))
    }
}
