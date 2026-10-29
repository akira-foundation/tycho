import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct PaletteRunnerTests {
    private let container: ModelContainer
    private let context: ModelContext
    private let defaults: UserDefaults
    private let router: Router

    init() throws {
        container = try TychoSchema.makeContainer(inMemory: true)
        context = ModelContext(container)
        let suite = "PaletteRunnerTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        router = Router(defaults: defaults)
    }

    private func runner(toggleTheme: @escaping @MainActor () -> Void = {}) -> PaletteRunner {
        PaletteRunner(context: context, defaults: defaults, toggleTheme: toggleTheme)
    }

    @Test func runningClosesThePaletteFirst() {
        let taskID = UUID()
        router.openPalette(mode: .commands)
        runner().run(.openTask(taskID), router: router)
        #expect(router.palette == nil)
        #expect(router.inspectedTaskID == taskID)
        router.openPalette(mode: .commands)
        runner().run(.go(.calendar), router: router)
        #expect(router.palette == nil)
        #expect(router.route == .calendar)
    }

    @Test func viewAllRecordsTheSearchAndOpensTheSearchPage() {
        RecentSearches.save(["older"], to: defaults)
        router.openPalette(mode: .search)
        runner().run(.viewAll("brand", .files), router: router)
        #expect(router.palette == nil)
        #expect(router.route == .search)
        #expect(router.searchQuery == "brand")
        #expect(router.searchScope == .files)
        #expect(RecentSearches.load(from: defaults) == ["brand", "older"])
    }

    @Test func fillQueryKeepsThePaletteOpen() {
        router.openPalette(mode: .search)
        router.palette?.highlight = 3
        runner().run(.fillQuery("homepage"), router: router)
        #expect(router.palette?.mode == .search)
        #expect(router.palette?.query == "homepage")
        #expect(router.palette?.highlight == 0)
    }

    @Test func searchModeReopensInSearchMode() {
        router.openPalette(mode: .commands)
        router.palette?.query = "sea"
        runner().run(.searchMode, router: router)
        #expect(router.palette == PaletteState(mode: .search))
    }

    @Test func openFileOpensItsProjectFilesTab() throws {
        let project = Project(key: "WEB", name: "Website Redesign")
        let file = FileRecord(name: "brief.pdf", byteCount: 10, uploadedAt: .now)
        context.insert(project)
        context.insert(file)
        file.project = project
        try context.save()
        router.openPalette(mode: .search)
        runner().run(.openFile(file.id), router: router)
        #expect(router.palette == nil)
        #expect(router.route == .project(project.id, .files))
    }

    @Test func toggleActionsReachTheirTargets() {
        var toggled = 0
        let runner = runner { toggled += 1 }
        runner.run(.toggleTheme, router: router)
        runner.run(.shortcuts, router: router)
        let projectID = UUID()
        runner.run(.openProject(projectID), router: router)
        #expect(toggled == 1)
        #expect(router.isShowingShortcuts)
        #expect(router.route == .project(projectID, .board))
        router.columnVisibility = .all
        runner.run(.toggleSidebar, router: router)
        #expect(router.columnVisibility == .detailOnly)
        runner.run(.toggleSidebar, router: router)
        #expect(router.columnVisibility == .all)
    }
}
