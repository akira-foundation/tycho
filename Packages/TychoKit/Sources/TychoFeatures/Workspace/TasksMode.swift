import Foundation
import TychoCore

enum TasksMode: String, CaseIterable, Identifiable {
    case list
    case board
    case table

    static let legacyKey = "tasks.mode"

    init(state: TaskViewState) {
        self = state.mode.flatMap(TasksMode.init(rawValue:)) ?? .list
    }

    var id: String { rawValue }

    var title: String {
        switch self {
        case .list: "List"
        case .board: "Board"
        case .table: "Table"
        }
    }

    var symbol: String {
        switch self {
        case .list: "list.bullet"
        case .board: "rectangle.split.3x1"
        case .table: "tablecells"
        }
    }

    static func subtitle(projectCount: Int) -> String { "Every task across \(projectCount) projects." }

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
