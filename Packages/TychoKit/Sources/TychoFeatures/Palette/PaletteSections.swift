import Foundation
import TychoCore

public enum PaletteSections {
    static let commandLimit = 5
    static let recentTaskLimit = 4

    public static func sections(
        for state: PaletteState,
        commands: [PaletteCommand],
        recentTasks: [TaskItem],
        results: SearchResults,
        recentSearches: [String],
        suggestions: [PaletteItem]
    ) -> [PaletteSection] {
        let text = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        switch (state.mode, text.isEmpty) {
        case (.commands, true):
            return emptyCommandSections(commands: commands, recentTasks: recentTasks)
        case (.commands, false):
            let matches = commands.filter { $0.title.localizedCaseInsensitiveContains(text) }
            let commandSection = PaletteSection(
                id: "commands", title: "Commands",
                items: matches.prefix(commandLimit).map(PaletteItem.init))
            let groups = PaletteEntityItems.groups(scope: .all, results: results)
            return withViewAll(
                ([commandSection].filter { !$0.items.isEmpty }) + groups, text: text)
        case (.search, true):
            return emptySearchSections(recentSearches: recentSearches, suggestions: suggestions)
        case (.search, false):
            return withViewAll(
                PaletteEntityItems.groups(scope: state.scope, results: results), text: text)
        }
    }

    public static func flattened(_ sections: [PaletteSection]) -> [PaletteItem] {
        sections.flatMap(\.items)
    }

    public static func moved(_ highlight: Int, by delta: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((highlight + delta) % count + count) % count
    }

    private static func emptyCommandSections(
        commands: [PaletteCommand], recentTasks: [TaskItem]
    ) -> [PaletteSection] {
        let suggested = commands.prefix(3) + commands.filter { $0.id == PaletteCommands.themeID }
        let recent = recentTasks.sorted { $0.updatedAt > $1.updatedAt }.prefix(recentTaskLimit)
        let sections = [
            PaletteSection(
                id: "suggestions", title: "Suggestions", items: suggested.map(PaletteItem.init)),
            PaletteSection(
                id: "recent-tasks", title: "Recent tasks",
                items: recent.map(PaletteEntityItems.task)),
            PaletteSection(
                id: "navigation", title: "Navigation",
                items: commands.filter { $0.title.hasPrefix("Go to") }.map(PaletteItem.init)),
        ]
        return sections.filter { !$0.items.isEmpty }
    }

    private static func emptySearchSections(
        recentSearches: [String], suggestions: [PaletteItem]
    ) -> [PaletteSection] {
        let recent = recentSearches.prefix(RecentSearches.limit).map { query in
            PaletteItem(
                id: "recent-\(query)", title: query, symbol: "clock.arrow.circlepath",
                kind: .recentSearch, action: .fillQuery(query))
        }
        let sections = [
            PaletteSection(id: "recent-searches", title: "Recent searches", items: Array(recent)),
            PaletteSection(id: "suggested", title: "Suggested", items: suggestions),
        ]
        return sections.filter { !$0.items.isEmpty }
    }

    private static func withViewAll(_ groups: [PaletteSection], text: String) -> [PaletteSection] {
        let item = PaletteItem(
            id: "view-all", title: "View all results for “\(text)”", symbol: "magnifyingglass",
            kind: .viewAll, action: .viewAll(text))
        return groups + [PaletteSection(id: "view-all", title: "", items: [item])]
    }
}
