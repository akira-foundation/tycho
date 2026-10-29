import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct TasksModeTests {
    private func makeDefaults() throws -> UserDefaults {
        let suite = "TasksModeTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func storedState(_ defaults: UserDefaults) -> TaskViewState {
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        return TaskViewStates.state(for: TaskViewStates.tasksKey, inProject: false, in: data)
    }

    @Test func modesFollowTheOriginal() {
        #expect(TasksMode.allCases.map(\.title) == ["List", "Board", "Table"])
        #expect(TasksMode.list.rawValue == "list")
    }

    @Test func subtitleCountsTheProjects() {
        #expect(TasksMode.subtitle(projectCount: 7) == "Every task across 7 projects.")
    }

    @Test func modeComesFromTheViewState() {
        var state = TaskViewState(inProject: false)
        #expect(TasksMode(state: state) == .list)
        state.mode = "table"
        #expect(TasksMode(state: state) == .table)
        state.mode = "gallery"
        #expect(TasksMode(state: state) == .list)
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
