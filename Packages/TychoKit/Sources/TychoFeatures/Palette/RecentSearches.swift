import Foundation

public enum RecentSearches {
    public static let key = "search.recent"
    public static let limit = 5

    public static func adding(_ query: String, to list: [String]) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return list }
        return Array(([trimmed] + list.filter { $0 != trimmed }).prefix(limit))
    }

    public static func load(from defaults: UserDefaults) -> [String] {
        guard let data = defaults.data(forKey: key),
            let list = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return list
    }

    public static func save(_ list: [String], to defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        defaults.set(data, forKey: key)
    }
}
