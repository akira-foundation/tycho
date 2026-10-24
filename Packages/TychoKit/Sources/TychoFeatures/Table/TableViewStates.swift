import Foundation
import TychoCore

enum TableViewStates {
    static let storageKey = "table.views"
    static let workspaceKey = "tasks"

    static func projectKey(_ id: UUID) -> String { "p:\(id.uuidString)" }

    static func state(for key: String, inProject: Bool, in data: Data) -> TableViewState {
        guard var stored = decode(data)[key] else { return TableViewState(inProject: inProject) }
        if inProject && !hasStoredVisibility(for: key, in: data) {
            stored.hidden = TableColumnID.defaultHidden(inProject: true)
        }
        stored.hidden.remove(.title)
        return stored
    }

    static func storing(_ state: TableViewState, for key: String, in data: Data) -> Data {
        var all = decode(data)
        all[key] = state
        return (try? JSONEncoder().encode(all)) ?? data
    }

    private static func decode(_ data: Data) -> [String: TableViewState] {
        (try? JSONDecoder().decode([String: TableViewState].self, from: data)) ?? [:]
    }

    private static func hasStoredVisibility(for key: String, in data: Data) -> Bool {
        let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        return (object?[key] as? [String: Any])?["hidden"] != nil
    }
}
