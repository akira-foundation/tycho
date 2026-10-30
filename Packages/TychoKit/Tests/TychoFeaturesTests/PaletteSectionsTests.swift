import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct PaletteSectionsTests {
    private let commands = PaletteCommands.all(isDark: false)

    private func state(_ mode: PaletteMode, query: String = "", scope: SearchScope = .all) -> PaletteState {
        var state = PaletteState(mode: mode)
        state.query = query
        state.scope = scope
        return state
    }

    private func makeTasks(_ count: Int, titlePrefix: String = "Task") -> [TaskItem] {
        let project = Project(key: "WEB", name: "Website Redesign")
        return (1...count).map { index in
            let task = TaskItem(number: index, title: "\(titlePrefix) \(index)")
            task.project = project
            task.updatedAt = Date(timeIntervalSince1970: Double(index))
            return task
        }
    }

    private func sections(
        _ state: PaletteState, recent: [TaskItem] = [], results: SearchResults = SearchResults(),
        recentSearches: [String] = [], suggestions: [PaletteItem] = []
    ) -> [PaletteSection] {
        PaletteSections.sections(
            for: state, commands: commands, recentTasks: recent, results: results,
            recentSearches: recentSearches, suggestions: suggestions)
    }

    @Test func emptyCommandModeShowsSuggestionsRecentTasksAndNavigation() {
        let result = sections(state(.commands), recent: makeTasks(6))
        #expect(result.map(\.title) == ["Suggestions", "Recent tasks", "Navigation"])
        #expect(
            result[0].items.map(\.title) == [
                "Create task", "Create project", "Search workspace", "Switch to dark mode",
            ])
        #expect(result[1].items.count == 4)
        #expect(result[1].items.map(\.title) == ["Task 6", "Task 5", "Task 4", "Task 3"])
        #expect(result[1].items[0].subtitle == "Website Redesign")
        #expect(result[1].items[0].trailing == "WEB-6")
        #expect(result[2].items.allSatisfy { $0.title.hasPrefix("Go to") })
        #expect(result[2].items.count == 6)
    }

    @Test func typedCommandModeCapsCommandsAtFiveAndAppendsEntities() {
        let results = SearchResults(tasks: makeTasks(2, titlePrefix: "Go"))
        let result = sections(state(.commands, query: "o"), results: results)
        #expect(result.map(\.title) == ["Commands", "Tasks", ""])
        #expect(result[0].items.count == 5)
        #expect(result[1].items.count == 2)
        #expect(result[1].items[0].action == .openTask(results.tasks[0].id))
    }

    @Test func searchModeEmptyShowsRecentAndSuggested() {
        let suggestions = PaletteSuggestions.items(projects: [], savedViews: [])
        let result = sections(
            state(.search), recentSearches: ["alpha", "beta"], suggestions: suggestions)
        #expect(result.map(\.title) == ["Recent searches", "Suggested"])
        #expect(result[0].items.map(\.action) == [.fillQuery("alpha"), .fillQuery("beta")])
        #expect(result[1].items.map(\.title) == ["Overdue tasks", "Tasks assigned to me"])
        #expect(sections(state(.search)).isEmpty)
    }

    @Test func entityGroupsCapAtFourInAllAndTwelveInAScope() {
        let tasks = makeTasks(20)
        let results = SearchResults(tasks: tasks)
        let all = sections(state(.search, query: "task"), results: results)
        let scoped = sections(state(.search, query: "task", scope: .tasks), results: results)
        #expect(all[0].items.count == 4)
        #expect(scoped[0].items.count == 12)
    }

    @Test func scopeKeepsOnlyTheMatchingGroup() {
        let project = Project(key: "WEB", name: "Website Redesign")
        project.statusRaw = ProjectStatus.active.rawValue
        let file = FileRecord(name: "brief.pdf", byteCount: 2048, uploadedAt: .now)
        file.project = project
        let results = SearchResults(tasks: makeTasks(1), projects: [project], files: [file])
        let files = sections(state(.search, query: "w", scope: .files), results: results)
        let projects = sections(state(.search, query: "w", scope: .projects), results: results)
        #expect(files.map(\.title) == ["Files", ""])
        #expect(files[0].items[0].subtitle == "Website Redesign")
        #expect(files[0].items[0].trailing == ByteCountText.format(2048))
        #expect(files[0].items[0].action == .openFile(file.id))
        #expect(projects.map(\.title) == ["Projects", ""])
        #expect(projects[0].items[0].subtitle == "In Progress")
        #expect(projects[0].items[0].action == .openProject(project.id))
    }

    @Test func viewAllIsAlwaysLastWhenThereIsAQuery() {
        let withResults = sections(
            state(.search, query: "task"), results: SearchResults(tasks: makeTasks(1)))
        let withoutResults = sections(state(.search, query: "zzz"))
        #expect(withResults.last?.items.last?.title == "View all results for “task”")
        #expect(withResults.last?.items.last?.action == .viewAll("task", .all))
        #expect(withoutResults.count == 1)
        #expect(withoutResults[0].items[0].kind == .viewAll)
    }

    @Test func rowScrollTargetsNeverCollideWithSectionIDs() {
        let result = sections(state(.search, query: "task"), results: SearchResults(tasks: makeTasks(1)))
        let sectionIDs = Set(result.map(\.id))
        let rowIDs = Set(PaletteSections.flattened(result).map(PalettePanel.rowID))
        #expect(sectionIDs.contains("view-all"))
        #expect(sectionIDs.isDisjoint(with: rowIDs))
    }

    @Test func emptyGroupsAreDropped() {
        let result = sections(
            state(.commands, query: "zzz"), results: SearchResults(tasks: makeTasks(1)))
        #expect(result.map(\.title) == ["Tasks", ""])
        #expect(sections(state(.commands), recent: []).map(\.title) == ["Suggestions", "Navigation"])
    }

    @Test func highlightWraps() {
        #expect(PaletteSections.moved(0, by: -1, count: 5) == 4)
        #expect(PaletteSections.moved(4, by: 1, count: 5) == 0)
        #expect(PaletteSections.moved(2, by: 1, count: 5) == 3)
        #expect(PaletteSections.moved(3, by: 1, count: 0) == 0)
        let flat = PaletteSections.flattened(sections(state(.commands), recent: makeTasks(1)))
        #expect(flat.count == 4 + 1 + 6)
    }

    @Test func themeCommandFollowsTheCurrentTheme() {
        let light = PaletteCommands.all(isDark: false)
        let dark = PaletteCommands.all(isDark: true)
        #expect(light.first { $0.id == PaletteCommands.themeID }?.title == "Switch to dark mode")
        #expect(dark.first { $0.id == PaletteCommands.themeID }?.title == "Switch to light mode")
        #expect(
            light.map(\.title) == [
                "Create task", "Create project", "Search workspace", "Go to Home", "Go to My Tasks",
                "Go to Tasks", "Go to Projects", "Go to Calendar", "Go to Timeline", "Open settings",
                "Appearance settings", "Switch to dark mode", "Toggle sidebar", "Keyboard shortcuts",
            ])
        #expect(
            light.map(\.hint) == [
                "N", "P", "/", "G H", "G T", nil, "G P", "G C", nil, "G S", nil, "⌘ ⇧ L", "[", "?",
            ])
    }

    @Test func suggestionsOmitWebsiteItemsWithoutTheProjectOrView() {
        let website = Project(key: "WEB", name: "Website Redesign")
        let view = SavedView(name: "High priority", layout: .list)
        view.project = website
        let full = PaletteSuggestions.items(projects: [website], savedViews: [view])
        let noView = PaletteSuggestions.items(projects: [website], savedViews: [])
        let none = PaletteSuggestions.items(projects: [], savedViews: [view])
        #expect(
            full.map(\.title) == [
                "Overdue tasks", "Tasks assigned to me", "High priority in Website Redesign",
                "Files in Website Redesign",
            ])
        #expect(full[0].action == .tasksPreset(.overdue))
        #expect(full[1].action == .go(.myTasks))
        #expect(full[2].action == .go(.project(website.id, .savedView(view.id))))
        #expect(full[3].action == .go(.project(website.id, .files)))
        #expect(noView.map(\.title) == ["Overdue tasks", "Tasks assigned to me", "Files in Website Redesign"])
        #expect(none.map(\.title) == ["Overdue tasks", "Tasks assigned to me"])
    }

    @Test func itemsCarryTheirVisuals() {
        let project = Project(key: "WEB", name: "Website Redesign")
        project.symbol = "globe"
        project.colorRaw = ProjectColor.indigo.rawValue
        let task = makeTasks(1)[0]
        task.statusRaw = TaskStatus.done.rawValue
        let file = FileRecord(name: "a.png", byteCount: 1, uploadedAt: .now)
        file.typeRaw = FileKind.img.rawValue
        let results = SearchResults(tasks: [task], projects: [project], files: [file])
        let result = sections(state(.search, query: "a"), results: results)
        #expect(result[0].items[0].visual == .status(.done))
        #expect(result[1].items[0].visual == .project(symbol: "globe", color: .indigo))
        #expect(result[2].items[0].visual == .file(.img))
    }

    @Test func viewAllCarriesTheScopeAndNavigationFollowsGoActions() {
        let scoped = sections(state(.search, query: "q", scope: .files))
        let typed = sections(state(.commands, query: "q"))
        #expect(scoped.last?.items.last?.action == .viewAll("q", .files))
        #expect(typed.last?.items.last?.action == .viewAll("q", .all))
        let navigation = sections(state(.commands))[1]
        #expect(navigation.items.allSatisfy { if case .go = $0.action { true } else { false } })
    }

    @Test func duplicateRecentSearchesKeepIdsUnique() {
        let result = sections(state(.search), recentSearches: ["a", "a", "b"])
        #expect(result[0].items.map(\.id) == ["recent-a", "recent-b"])
    }
}
