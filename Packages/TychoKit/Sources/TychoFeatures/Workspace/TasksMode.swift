import Foundation
import TychoCore

enum TasksMode: String, TaskViewMode {
    case list
    case board
    case table

    static let legacyKey = "tasks.mode"
    static let fallback = TasksMode.list

    @MainActor
    static func current(in model: TaskViewModel) -> TasksMode {
        TasksMode(state: model.state)
    }

    var layout: ProjectBuiltInTab {
        switch self {
        case .list: .list
        case .board: .board
        case .table: .table
        }
    }

    static func preset(of state: TaskViewState) -> TasksPreset? {
        state.query.isEmpty ? TasksPreset.matching(state.filters) : nil
    }

    static func title(state: TaskViewState) -> String {
        preset(of: state)?.title ?? "Tasks"
    }

    static func subtitle(projectCount: Int, state: TaskViewState) -> String {
        preset(of: state)?.subtitle(projectCount: projectCount) ?? "Every task across \(projectCount) projects."
    }

    static func migrateLegacyPreference(_ defaults: UserDefaults) {
        guard let legacy = defaults.string(forKey: legacyKey) else { return }
        defaults.removeObject(forKey: legacyKey)
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        var state = TaskViewStates.state(for: TaskViewStates.tasksKey, inProject: false, in: data)
        guard state.mode == nil, let mode = TasksMode(rawValue: legacy) else { return }
        state.mode = mode.rawValue
        defaults.set(
            TaskViewStates.storing(state, for: TaskViewStates.tasksKey, in: data), forKey: TaskViewStates.storageKey)
    }
}
