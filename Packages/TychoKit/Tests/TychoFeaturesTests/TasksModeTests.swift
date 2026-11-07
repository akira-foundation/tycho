import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct TasksModeTests {
    private func makeDefaults() throws -> UserDefaults {
        try ScratchDefaults.numbered("tasks-mode").defaults
    }

    private func storedState(_ defaults: UserDefaults) -> TaskViewState {
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        return TaskViewStates.state(for: TaskViewStates.tasksKey, inProject: false, in: data)
    }

    @Test func modesFollowTheOriginal() {
        #expect(TasksMode.allCases.map(\.title) == ["List", "Board", "Table"])
        #expect(TasksMode.list.rawValue == "list")
    }

    @Test func tasksModesShareTheProjectViewSymbols() {
        #expect(TasksMode.allCases.map(\.symbol) == [ProjectBuiltInTab.list, .board, .table].map(\.symbol))
    }

    private func state(_ filters: [TaskFilter], query: String = "") -> TaskViewState {
        var state = TaskViewState(inProject: false)
        state.filters = filters
        state.query = query
        return state
    }

    @Test func subtitleCountsTheProjects() {
        #expect(TasksMode.subtitle(projectCount: 7, state: state([])) == "Every task across 7 projects.")
    }

    @Test func homePresetsNameTheList() {
        #expect(
            TasksPreset.allCases.map { TasksMode.title(state: state($0.filters)) } == [
                "Open Tasks", "Completed", "Overdue",
            ])
        #expect(
            TasksMode.subtitle(projectCount: 7, state: state(TasksPreset.overdue.filters))
                == "Overdue tasks across 7 projects.")
        #expect(
            TasksMode.subtitle(projectCount: 7, state: state(TasksPreset.done.filters))
                == "Done tasks updated in the last 7 days across 7 projects.")
        #expect(
            TasksMode.subtitle(projectCount: 7, state: state(TasksPreset.open.filters))
                == "Open tasks across 7 projects.")
    }

    @Test func changedFiltersFallBackToTheTasksHeading() {
        let edited = TasksPreset.overdue.filters + [TaskFilter(field: .priority, values: ["high"])]
        #expect(TasksMode.title(state: state(edited)) == "Tasks")
        #expect(TasksMode.subtitle(projectCount: 7, state: state(edited)) == "Every task across 7 projects.")
    }

    @Test func aSearchFallsBackToTheTasksHeading() {
        let searched = state(TasksPreset.overdue.filters, query: "budget")
        #expect(TasksMode.title(state: searched) == "Tasks")
        #expect(TasksMode.subtitle(projectCount: 7, state: searched) == "Every task across 7 projects.")
    }

    @Test func modeComesFromTheViewState() {
        var state = TaskViewState(inProject: false)
        #expect(TasksMode(state: state) == .list)
        state.mode = "table"
        #expect(TasksMode(state: state) == .table)
        state.mode = "gallery"
        #expect(TasksMode(state: state) == .list)
    }

    @MainActor
    @Test func theViewModeFollowsTheStoredStateAndHomePresets() throws {
        let defaults = try makeDefaults()
        var board = TaskViewState(inProject: false)
        board.mode = "board"
        defaults.set(
            TaskViewStates.storing(board, for: TaskViewStates.tasksKey, in: Data()),
            forKey: TaskViewStates.storageKey)
        let model = TaskViewModel(key: TaskViewStates.tasksKey, inProject: false, defaults: defaults)

        #expect(TasksMode.current(in: model) == .board)

        Router(defaults: defaults).openTasks(preset: .overdue)

        #expect(TasksMode.current(in: model) == .list)
        #expect(model.state.filters == TasksPreset.overdue.filters)
    }

    @Test func tasksModeMigratesFromTheOldPreference() throws {
        let defaults = try makeDefaults()
        defaults.set("board", forKey: TasksMode.legacyKey)

        TasksMode.migrateLegacyPreference(defaults)

        #expect(storedState(defaults).mode == "board")
        #expect(defaults.string(forKey: TasksMode.legacyKey) == nil)
    }

    @Test func storedModeWinsOverTheOldPreference() throws {
        let defaults = try makeDefaults()
        var state = TaskViewState(inProject: false)
        state.mode = "table"
        defaults.set(
            TaskViewStates.storing(state, for: TaskViewStates.tasksKey, in: Data()),
            forKey: TaskViewStates.storageKey)
        defaults.set("board", forKey: TasksMode.legacyKey)

        TasksMode.migrateLegacyPreference(defaults)
        TasksMode.migrateLegacyPreference(defaults)

        #expect(storedState(defaults).mode == "table")
        #expect(defaults.string(forKey: TasksMode.legacyKey) == nil)
    }

    @Test func anInvalidOldPreferenceIsDropped() throws {
        let defaults = try makeDefaults()
        defaults.set("gallery", forKey: TasksMode.legacyKey)

        TasksMode.migrateLegacyPreference(defaults)

        #expect(storedState(defaults).mode == nil)
        #expect(defaults.string(forKey: TasksMode.legacyKey) == nil)
    }
}
