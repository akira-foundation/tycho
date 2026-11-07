import SwiftData
import SwiftUI
import TychoCore

struct SearchPage: View {
    @Environment(Router.self) private var router
    @Environment(\.modelContext) private var context
    @State private var results = SearchResults()
    @State private var recent: [String] = []
    @FocusState private var isSearchFocused: Bool

    private var query: String { router.searchQuery }
    private var isBlank: Bool { query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        @Bindable var router = router
        let counts = SearchPageModel.counts(results)
        content
            .navigationTitle("Search")
            .searchable(text: $router.searchQuery, prompt: "Search Tasks, Projects, and Files")
            .searchFocused($isSearchFocused)
            .marksTextEditing(isFocused: isSearchFocused)
            .searchScopes($router.searchScope) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text("\(scope.title) \(counts[scope] ?? 0)").tag(scope)
                }
            }
            .task(id: router.searchQuery) { refresh() }
            .onAppear {
                recent = RecentSearches.load(from: TychoDefaults.current)
                isSearchFocused = true
            }
    }

    @ViewBuilder private var content: some View {
        switch (isBlank, results.isEmpty) {
        case (true, _): recentSearches
        case (false, true): ContentUnavailableView.search(text: query)
        case (false, false): SearchResultsList(results: results, scope: router.searchScope, query: query)
        }
    }

    @ViewBuilder private var recentSearches: some View {
        if recent.isEmpty {
            ContentUnavailableView(
                "Search", systemImage: "magnifyingglass", description: Text("Find tasks, projects, and files."))
        } else {
            List {
                Section("Recent Searches") {
                    ForEach(recent, id: \.self) { text in
                        Button(text, systemImage: "clock.arrow.circlepath") { router.searchQuery = text }
                    }
                }
            }
        }
    }

    private func refresh() {
        results = (try? SearchIndex.search(query, in: context)) ?? SearchResults()
    }
}
