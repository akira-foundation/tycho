import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct PaletteOverlay: View {
    @Environment(Router.self) private var router

    var body: some View {
        if let state = router.palette {
            PaletteContent(state: state)
        }
    }
}

private struct PaletteContent: View {
    let state: PaletteState
    @Environment(Router.self) private var router
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system
    @Query(sort: \TaskItem.updatedAt, order: .reverse) private var tasks: [TaskItem]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @Query(sort: \SavedView.sortOrder) private var savedViews: [SavedView]
    @State private var results = SearchResults()

    static let searchLimit = 12

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Token.overlay.color
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { router.closePalette() }
                    .accessibilityHidden(true)
                PalettePanel(
                    state: binding, sections: sections, onRun: run,
                    onClose: { router.closePalette() }
                )
                .frame(maxWidth: min(640, max(proxy.size.width - 32, 0)))
                .frame(maxHeight: proxy.size.height * 0.7, alignment: .top)
                .padding(.top, proxy.size.height * 0.12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: state.query, initial: true) { search(state.query) }
    }

    private var binding: Binding<PaletteState> {
        Binding(
            get: { router.palette ?? PaletteState(mode: .commands) },
            set: { if router.palette != nil { router.palette = $0 } }
        )
    }

    private var sections: [PaletteSection] {
        PaletteSections.sections(
            for: state,
            commands: PaletteCommands.all(isDark: colorScheme == .dark),
            recentTasks: recentTasks,
            results: results,
            recentSearches: RecentSearches.load(from: .standard),
            suggestions: PaletteSuggestions.items(projects: projects, savedViews: savedViews))
    }

    private var recentTasks: [TaskItem] {
        tasks.filter { task in
            (task.assignee?.isMe == true || task.isFavorite) && task.project?.isArchived != true
        }
    }

    private func search(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = SearchResults()
            return
        }
        results = (try? SearchIndex.search(query, in: context, limit: Self.searchLimit)) ?? SearchResults()
    }

    private func run(_ item: PaletteItem) {
        let isDark = colorScheme == .dark
        let runner = PaletteRunner(context: context) { theme = .toggled(isDark: isDark) }
        runner.run(item.action, router: router)
    }
}

struct PaletteToolbarButton: View {
    @Environment(Router.self) private var router

    var body: some View {
        Button {
            router.togglePalette()
        } label: {
            #if os(macOS)
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(Token.text3.color)
                ShortcutKeyChip("⌘K")
            }
            .padding(.horizontal, 6)
            #else
            Label("Search or jump to…", systemImage: "magnifyingglass")
            #endif
        }
        .help("Search or jump to… (⌘K)")
        .accessibilityLabel("Search or jump to…")
        .accessibilityIdentifier("toolbar.palette")
    }
}
