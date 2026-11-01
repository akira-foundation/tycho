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
    @ObservationIgnored var liveProjectIDs: Set<UUID>?
    @ObservationIgnored var liveSavedViewIDs: Set<UUID>?
    private var cached: TaskViewState
    var editingFilterIndex: Int?

    init(key: String, inProject: Bool, defaults: UserDefaults = TychoDefaults.current) {
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

    static func project(_ id: UUID, defaults: UserDefaults = TychoDefaults.current) -> TaskViewModel {
        TaskViewModel(key: TaskViewStates.projectKey(id), inProject: true, defaults: defaults)
    }

    func seedFiltersIfUnsaved(_ filters: [TaskFilter]) {
        guard !TaskViewStates.contains(key, in: defaults.data(forKey: TaskViewStates.storageKey) ?? Data()) else {
            return
        }
        state.filters = filters
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
            let next = TaskViewStates.storing(
                newValue, for: key, in: stored, liveProjectIDs: liveProjectIDs, liveSavedViewIDs: liveSavedViewIDs)
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
        if next.filters != cached.filters { editingFilterIndex = nil }
        cached = next
    }

    func setQuery(_ query: String) {
        state.query = query
    }

    func setSort(field: TaskSortField) {
        let order = state.sort.first?.order ?? .forward
        state.sort = [TaskComparator(field: field, order: order)]
    }

    func setSort(_ comparators: [TaskComparator]) {
        state.sort = Array(comparators.prefix(1))
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

    func setField(at index: Int, to field: TaskFilterField) {
        updateFilter(at: index) {
            guard $0.field != field else { return }
            $0.field = field
            $0.values = []
        }
    }

    func removeFilter(at index: Int) {
        var next = state
        guard next.filters.indices.contains(index) else { return }
        next.filters.remove(at: index)
        editingFilterIndex = nil
        state = next
    }

    func clearFilters() {
        var next = state
        next.filters = []
        next.query = ""
        editingFilterIndex = nil
        state = next
    }

    func apply(_ tasks: [TaskItem], now: Date, calendar: Calendar) -> [TaskItem] {
        state.viewQuery.apply(tasks, now: now, calendar: calendar)
    }

    func groups(
        of visible: [TaskItem], members: [Member], projects: [Project], now: Date, calendar: Calendar
    ) -> [TaskViewGroup] {
        state.grouping.groups(visible, members: members, projects: projects, now: now, calendar: calendar)
    }
}
