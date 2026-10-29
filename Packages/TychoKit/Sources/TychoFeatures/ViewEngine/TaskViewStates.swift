import Foundation
import TychoCore

enum TaskViewStates {
    static let storageKey = "task.views"
    static let legacyKey = "table.views"
    static let tasksKey = "tasks"
    static let myTasksKey = "mytasks"
    static let calendarKey = "cal"
    static let timelineKey = "tl"

    static func projectKey(_ id: UUID) -> String { "p:\(id.uuidString)" }

    static func savedViewKey(_ id: UUID) -> String { "sv:\(id.uuidString)" }

    static func migrated(current: Data, legacy: Data) -> Data {
        current.isEmpty ? legacy : current
    }

    static func migrateStoredDefaults(_ defaults: UserDefaults = .standard) {
        let current = defaults.data(forKey: storageKey) ?? Data()
        guard current.isEmpty, let legacy = defaults.data(forKey: legacyKey) else { return }
        defaults.set(migrated(current: current, legacy: legacy), forKey: storageKey)
    }

    static func state(for key: String, inProject: Bool, in data: Data) -> TaskViewState {
        guard var stored = decode(data)[key] else { return TaskViewState(inProject: inProject) }
        if inProject && !hasStoredVisibility(for: key, in: data) {
            stored.hidden = TableColumnID.defaultHidden(inProject: true)
        }
        stored.hidden.remove(.title)
        return stored
    }

    static func storing(
        _ state: TaskViewState, for key: String, in data: Data, liveProjectIDs: Set<UUID>? = nil,
        liveSavedViewIDs: Set<UUID>? = nil
    ) -> Data {
        var all = decode(data)
        all[key] = state
        all = all.filter {
            isLive($0.key, prefix: "p:", in: liveProjectIDs) && isLive($0.key, prefix: "sv:", in: liveSavedViewIDs)
        }
        return (try? JSONEncoder().encode(all)) ?? data
    }

    private struct Entry: Decodable {
        let state: TaskViewState?

        init(from decoder: any Decoder) throws {
            state = try? TaskViewState(from: decoder)
        }
    }

    private static func decode(_ data: Data) -> [String: TaskViewState] {
        let entries = (try? JSONDecoder().decode([String: Entry].self, from: data)) ?? [:]
        return entries.compactMapValues(\.state)
    }

    private static func isLive(_ key: String, prefix: String, in liveIDs: Set<UUID>?) -> Bool {
        guard let liveIDs, key.hasPrefix(prefix), let id = UUID(uuidString: String(key.dropFirst(prefix.count)))
        else { return true }
        return liveIDs.contains(id)
    }

    private static func hasStoredVisibility(for key: String, in data: Data) -> Bool {
        let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        return (object?[key] as? [String: Any])?["hidden"] != nil
    }
}
