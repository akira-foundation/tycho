import Foundation
import Observation
import SwiftUI
import TychoCore

@MainActor
@Observable
final class TaskViewModel {
    @ObservationIgnored private let key: String
    @ObservationIgnored private let inProject: Bool
    @ObservationIgnored private let defaults: UserDefaults
    private var revision = 0

    init(key: String, inProject: Bool, defaults: UserDefaults = .standard) {
        self.key = key
        self.inProject = inProject
        self.defaults = defaults
    }

    var state: TaskViewState {
        get {
            _ = revision
            return TaskViewStates.state(
                for: key, inProject: inProject, in: defaults.data(forKey: TaskViewStates.storageKey) ?? Data())
        }
        set {
            let stored = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
            defaults.set(TaskViewStates.storing(newValue, for: key, in: stored), forKey: TaskViewStates.storageKey)
            revision += 1
        }
    }

    func setQuery(_ query: String) {
        state.query = query
    }

    func setSort(field: TaskSortField) {
        let order = state.sort.first?.order ?? .forward
        state.sort = [TaskComparator(field: field, order: order)]
    }

    func setSortOrder(_ order: SortOrder) {
        let field = state.sort.first?.field ?? .manual
        state.sort = [TaskComparator(field: field, order: order)]
    }

    func setGrouping(_ grouping: TaskViewGrouping) {
        state.grouping = grouping
    }

    func addFilter(_ field: TaskFilterField) -> Int {
        var next = state
        next.filters.append(TaskFilter(field: field))
        state = next
        return next.filters.count - 1
    }

    func updateFilter(at index: Int, _ change: (inout TaskFilter) -> Void) {
        var next = state
        guard next.filters.indices.contains(index) else { return }
        change(&next.filters[index])
        state = next
    }

    func removeFilter(at index: Int) {
        var next = state
        guard next.filters.indices.contains(index) else { return }
        next.filters.remove(at: index)
        state = next
    }

    func clearFilters() {
        var next = state
        next.filters = []
        next.query = ""
        state = next
    }

    func apply(_ tasks: [TaskItem], now: Date, calendar: Calendar) -> [TaskItem] {
        state.viewQuery.apply(tasks, now: now, calendar: calendar)
    }
}
