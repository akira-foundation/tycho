import Foundation
import SwiftData
import SwiftUI
import TychoCore

@MainActor
struct PaletteRunner {
    let context: ModelContext
    let defaults: UserDefaults
    let toggleTheme: @MainActor () -> Void

    init(context: ModelContext, defaults: UserDefaults = .standard, toggleTheme: @escaping @MainActor () -> Void) {
        self.context = context
        self.defaults = defaults
        self.toggleTheme = toggleTheme
    }

    func run(_ action: PaletteAction, router: Router) {
        let previous = router.palette
        router.closePalette()
        switch action {
        case .newTask: router.newTask()
        case .newProject: router.newProject()
        case .searchMode: router.openPalette(mode: .search)
        case .go(let route): router.open(route)
        case .settings, .appearanceSettings: router.showSettings()
        case .toggleTheme: toggleTheme()
        case .toggleSidebar: router.toggleSidebar()
        case .shortcuts: router.showShortcuts()
        case .openTask(let id): router.inspect(id)
        case .openProject(let id): router.openProject(id, tab: .board)
        case .openFile(let id): openFile(id, router: router)
        case .fillQuery(let query): fill(query, previous: previous, router: router)
        case .viewAll(let query, let scope): viewAll(query, scope: scope, router: router)
        case .tasksPreset(let preset): router.openTasks(preset: preset)
        }
    }

    private func openFile(_ id: UUID, router: Router) {
        let descriptor = FetchDescriptor<FileRecord>(predicate: #Predicate { $0.id == id })
        guard let projectID = (try? context.fetch(descriptor))?.first?.project?.id else { return }
        router.openProject(projectID, tab: .files)
    }

    private func fill(_ query: String, previous: PaletteState?, router: Router) {
        var state = previous ?? PaletteState(mode: .search)
        state.query = query
        state.highlight = 0
        router.palette = state
    }

    private func viewAll(_ query: String, scope: SearchScope, router: Router) {
        RecentSearches.save(RecentSearches.adding(query, to: RecentSearches.load(from: defaults)), to: defaults)
        router.searchQuery = query
        router.searchScope = scope
        router.open(.search)
    }
}
