import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ProjectViewEngineTests {
    private let calendar = Calendar(identifier: .gregorian)

    private func makeDefaults() throws -> UserDefaults {
        let suite = "ProjectViewEngineTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func task(_ number: Int, _ title: String, priority: TaskPriority) -> TaskItem {
        let task = TaskItem(number: number, title: title)
        task.priority = priority
        return task
    }

    @Test func projectTabsShareOneViewState() throws {
        let defaults = try makeDefaults()
        let id = UUID()
        let list = TaskViewModel.project(id, defaults: defaults)
        let table = TaskViewModel.project(id, defaults: defaults)

        list.addFilter(.status)
        list.updateFilter(at: 0) { $0.values = ["done"] }

        let data = try #require(defaults.data(forKey: TaskViewStates.storageKey))
        let stored = TaskViewStates.state(for: TaskViewStates.projectKey(id), inProject: true, in: data)
        #expect(table.state.filters == [TaskFilter(field: .status, values: ["done"])])
        #expect(stored.filters == table.state.filters)
        #expect(table.state.hidden == TableColumnID.defaultHidden(inProject: true))
    }

    @Test func listGroupingFollowsTheViewState() throws {
        let model = TaskViewModel.project(UUID(), defaults: try makeDefaults())
        let urgent = task(1, "Ship login", priority: .urgent)
        let low = task(2, "Ship docs", priority: .low)
        let hidden = task(3, "Water plants", priority: .high)
        model.setGrouping(.priority)
        model.setQuery("ship")

        let groups = model.groups([urgent, low, hidden], members: [], projects: [], now: Date(), calendar: calendar)

        #expect(groups.map(\.title) == ["Urgent", "High", "Medium", "Low", "No priority"])
        #expect(groups[0].tasks == [urgent])
        #expect(groups[1].tasks.isEmpty)
        #expect(groups[3].tasks == [low])
    }

    @Test func defaultGroupingIsStatusInManualOrder() throws {
        let model = TaskViewModel.project(UUID(), defaults: try makeDefaults())
        let second = TaskItem(number: 1, title: "b")
        second.sortOrder = 2
        let first = TaskItem(number: 2, title: "a")
        first.sortOrder = 1

        let groups = model.groups([second, first], members: [], projects: [], now: Date(), calendar: calendar)

        #expect(groups.map(\.id) == TaskStatus.allCases.map(\.rawValue))
        #expect(groups.first { $0.id == first.status.rawValue }?.tasks == [first, second])
    }

    @Test func tableHeaderSortWritesOneComparatorToTheSharedState() throws {
        let defaults = try makeDefaults()
        let id = UUID()
        let table = TaskViewModel.project(id, defaults: defaults)
        let list = TaskViewModel.project(id, defaults: defaults)

        table.setSort([TaskComparator(field: .priority, order: .reverse), TaskComparator(field: .title)])

        #expect(list.state.sort == [TaskComparator(field: .priority, order: .reverse)])
    }

    @Test func columnVisibilityNeverHidesTheTitle() throws {
        let model = TaskViewModel.project(UUID(), defaults: try makeDefaults())
        model.setVisible(false, for: .title)
        model.setVisible(false, for: .priority)
        model.setVisible(true, for: .estimate)

        #expect(!model.state.hidden.contains(.title))
        #expect(model.state.hidden.contains(.priority))
        #expect(!model.state.hidden.contains(.estimate))
    }

    @Test func resetWidthsDropsTheStoredColumns() throws {
        let model = TaskViewModel.project(UUID(), defaults: try makeDefaults())
        model.state.columns = Data([1, 2, 3])
        model.resetWidths()

        #expect(model.state.columns == nil)
    }

    @Test func pruningDropsEntriesOfDeletedProjects() throws {
        let defaults = try makeDefaults()
        let alive = UUID()
        let dead = TaskViewModel.project(UUID(), defaults: defaults)
        dead.setQuery("gone")
        let model = TaskViewModel.project(alive, defaults: defaults)
        model.setQuery("kept")

        model.prune(liveProjectIDs: [alive])

        let data = try #require(defaults.data(forKey: TaskViewStates.storageKey))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object.keys.sorted() == [TaskViewStates.projectKey(alive)])
        #expect(model.state.query == "kept")
    }

    @Test func filteredEmptyStateNeedsTasksHiddenByTheView() {
        #expect(FilteredEmptyState.applies(source: 3, visible: 0))
        #expect(!FilteredEmptyState.applies(source: 0, visible: 0))
        #expect(!FilteredEmptyState.applies(source: 3, visible: 1))
    }
}
