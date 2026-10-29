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

    static func storing(
        _ state: TableViewState, for key: String, in data: Data, liveProjectIDs: Set<UUID>? = nil
    ) -> Data {
        var all = decode(data)
        all[key] = state
        if let liveProjectIDs {
            all = all.filter { isLive($0.key, in: liveProjectIDs) }
        }
        return (try? JSONEncoder().encode(all)) ?? data
    }

    static func storingSort(
        _ sort: [TaskComparator], for key: String, inProject: Bool, in data: Data, liveProjectIDs: Set<UUID>? = nil
    ) -> Data {
        var next = state(for: key, inProject: inProject, in: data)
        next.sort = Array(sort.prefix(1))
        return storing(next, for: key, in: data, liveProjectIDs: liveProjectIDs)
    }

    private struct Entry: Decodable {
        let state: TableViewState?

        init(from decoder: any Decoder) throws {
            state = try? TableViewState(from: decoder)
        }
    }

    private static func decode(_ data: Data) -> [String: TableViewState] {
        let entries = (try? JSONDecoder().decode([String: Entry].self, from: data)) ?? [:]
        return entries.compactMapValues(\.state)
    }

    private static func isLive(_ key: String, in liveProjectIDs: Set<UUID>) -> Bool {
        guard key.hasPrefix("p:"), let id = UUID(uuidString: String(key.dropFirst(2))) else { return true }
        return liveProjectIDs.contains(id)
    }

    private static func hasStoredVisibility(for key: String, in data: Data) -> Bool {
        let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        return (object?[key] as? [String: Any])?["hidden"] != nil
    }
}
