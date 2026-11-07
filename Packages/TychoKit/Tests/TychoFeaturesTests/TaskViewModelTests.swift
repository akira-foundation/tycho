import Foundation
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskViewModelTests {
    private func makeDefaults() throws -> UserDefaults {
        try ScratchDefaults.numbered("task-view-model").defaults
    }

    private func makeModel(
        key: String = "tasks", inProject: Bool = false, defaults: UserDefaults? = nil
    ) throws -> TaskViewModel {
        TaskViewModel(key: key, inProject: inProject, defaults: try defaults ?? makeDefaults())
    }

    @Test func setSortKeepsTheDirection() throws {
        let model = try makeModel()
        model.setSort(field: .due)
        model.setSortOrder(.reverse)
        model.setSort(field: .priority)

        #expect(model.state.sort == [TaskComparator(field: .priority, order: .reverse)])
    }

    @Test func setSortOrderChangesOnlyTheDirection() throws {
        let model = try makeModel()
        model.setSort(field: .title)
        model.setSortOrder(.reverse)

        #expect(model.state.sort == [TaskComparator(field: .title, order: .reverse)])
    }

    @Test func togglingAValueSelectsItThenDeselectsIt() throws {
        let model = try makeModel()
        let index = model.addFilter(.status)

        model.toggleValue(TaskStatus.done.rawValue, inFilterAt: index)
        model.toggleValue(TaskStatus.todo.rawValue, inFilterAt: index)
        #expect(model.state.filters[index].values == [TaskStatus.done.rawValue, TaskStatus.todo.rawValue])

        model.toggleValue(TaskStatus.done.rawValue, inFilterAt: index)
        #expect(model.state.filters[index].values == [TaskStatus.todo.rawValue])
    }

    @Test func togglingAValueOfAMissingFilterChangesNothing() throws {
        let model = try makeModel()
        _ = model.addFilter(.status)

        model.toggleValue(TaskStatus.done.rawValue, inFilterAt: 3)

        #expect(model.state.filters.map(\.values) == [[]])
    }

    @Test func clearFiltersAlsoClearsTheQuery() throws {
        let model = try makeModel()
        model.setQuery("ship")
        _ = model.addFilter(.status)
        model.clearFilters()

        #expect(model.state.filters.isEmpty)
        #expect(model.state.query.isEmpty)
    }

    @Test func addFilterAppendsAnEmptyIsFilter() throws {
        let model = try makeModel()
        let first = model.addFilter(.status)
        let second = model.addFilter(.assignee)

        #expect(first == 0)
        #expect(second == 1)
        #expect(model.state.filters == [TaskFilter(field: .status), TaskFilter(field: .assignee)])
    }

    @Test func updateAndRemoveFilterIgnoreOutOfRangeIndexes() throws {
        let model = try makeModel()
        _ = model.addFilter(.status)
        model.updateFilter(at: 0) { $0.values = ["done"] }
        model.updateFilter(at: 5) { $0.values = ["x"] }
        model.removeFilter(at: 9)

        #expect(model.state.filters == [TaskFilter(field: .status, values: ["done"])])
        model.removeFilter(at: 0)
        #expect(model.state.filters.isEmpty)
    }

    @Test func setFieldClearsValuesOnlyWhenTheFieldChanges() throws {
        let model = try makeModel()
        _ = model.addFilter(.status)
        model.updateFilter(at: 0) { $0.values = ["done"] }
        model.setField(at: 0, to: .status)
        #expect(model.state.filters == [TaskFilter(field: .status, values: ["done"])])

        model.setField(at: 0, to: .priority)
        #expect(model.state.filters == [TaskFilter(field: .priority)])
    }

    @Test func changesPersistUnderTheViewKey() throws {
        let defaults = try makeDefaults()
        let model = try makeModel(key: "p:abc", inProject: true, defaults: defaults)
        model.setGrouping(.priority)
        model.setQuery("login")

        let data = try #require(defaults.data(forKey: TaskViewStates.storageKey))
        let stored = TaskViewStates.state(for: "p:abc", inProject: true, in: data)
        #expect(stored.grouping == .priority)
        #expect(stored.query == "login")
        #expect(stored == model.state)
    }

    @Test func twoModelsWithTheSameKeyShareState() throws {
        let defaults = try makeDefaults()
        let first = try makeModel(defaults: defaults)
        let second = try makeModel(defaults: defaults)
        first.setQuery("shared")
        second.setGrouping(.project)

        #expect(second.state.query == "shared")
        #expect(first.state.grouping == .project)
    }

    @Test func modelsWithDifferentKeysStayIndependent() throws {
        let defaults = try makeDefaults()
        let first = try makeModel(defaults: defaults)
        let second = try makeModel(key: "mytasks", defaults: defaults)
        first.setQuery("only first")

        #expect(second.state.query.isEmpty)
    }

    @Test func applyFiltersByTheQuery() throws {
        let match = TaskItem(number: 1, title: "Ship login")
        let other = TaskItem(number: 2, title: "Water plants")
        let model = try makeModel()
        model.setQuery("login")

        #expect(model.apply([match, other], now: Date(), calendar: Calendar(identifier: .gregorian)) == [match])
    }
}
