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
    @ObservationIgnored private var lastData: Data
    @ObservationIgnored private nonisolated(unsafe) var observer: (any NSObjectProtocol)?
    private var cached: TaskViewState

    init(key: String, inProject: Bool, defaults: UserDefaults = .standard) {
        self.key = key
        self.inProject = inProject
        self.defaults = defaults
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        lastData = data
        cached = TaskViewStates.state(for: key, inProject: inProject, in: data)
        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification, object: nil, queue: nil
        ) { [weak self] _ in
            guard Thread.isMainThread else {
                Task { @MainActor in self?.refreshFromDefaults() }
                return
            }
            MainActor.assumeIsolated { self?.refreshFromDefaults() }
        }
    }

    deinit {
        guard let observer else { return }
        NotificationCenter.default.removeObserver(observer)
    }

    var state: TaskViewState {
        get { cached }
        set {
            guard newValue != cached else { return }
            let stored = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
            let next = TaskViewStates.storing(newValue, for: key, in: stored)
            cached = newValue
            lastData = next
            defaults.set(next, forKey: TaskViewStates.storageKey)
        }
    }

    private func refreshFromDefaults() {
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        guard data != lastData else { return }
        lastData = data
        let next = TaskViewStates.state(for: key, inProject: inProject, in: data)
        guard next != cached else { return }
        cached = next
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

    @discardableResult
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
