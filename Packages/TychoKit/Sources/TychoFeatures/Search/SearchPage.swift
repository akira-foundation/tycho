import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SearchPage: View {
    @Environment(Router.self) private var router
    @Environment(\.modelContext) private var context
    @State private var results = SearchResults()
    @State private var recent: [String] = []

    private var query: String { router.searchQuery }
    private var isBlank: Bool { query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        @Bindable var router = router
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                field($router.searchQuery)
                tabs
                content
            }
            .frame(maxWidth: 860, alignment: .leading)
            .padding(Spacing.s6)
            .frame(maxWidth: .infinity)
        }
        .background(Token.bg.color)
        .task(id: router.searchQuery) { refresh() }
        .onAppear { recent = RecentSearches.load(from: .standard) }
    }

    private func field(_ text: Binding<String>) -> some View {
        HStack(spacing: Spacing.s2) {
            Image(systemName: "magnifyingglass").foregroundStyle(Token.text3.color)
            TextField("Search tasks, projects, and files", text: text)
                .marksTextEditing()
                .textFieldStyle(.plain)
                .tychoFont(.base)
                .accessibilityIdentifier("search.field")
        }
        .padding(.horizontal, Spacing.s3)
        .frame(height: 42)
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .strokeBorder(Token.border.color, lineWidth: 1))
    }

    private var tabs: some View {
        let counts = SearchPageModel.counts(results)
        return HStack(spacing: Spacing.s2) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Button {
                    router.searchScope = scope
                } label: {
                    Text("\(scope.title) \(counts[scope] ?? 0)")
                        .tychoFont(.sm, weight: router.searchScope == scope ? .semibold : .regular)
                        .foregroundStyle(router.searchScope == scope ? Token.text.color : Token.text3.color)
                        .padding(.horizontal, Spacing.s3)
                        .padding(.vertical, Spacing.s1)
                        .background(
                            router.searchScope == scope ? Token.surface2.color : Color.clear,
                            in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("search.tab.\(scope.rawValue)")
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch (isBlank, results.isEmpty) {
        case (true, _): recentSearches
        case (false, true): noResults
        case (false, false): SearchResultsList(results: results, scope: router.searchScope, query: query)
        }
    }

    private var recentSearches: some View {
        HStack(spacing: Spacing.s2) {
            Text("Recent:").tychoFont(.xs).foregroundStyle(Token.text3.color)
            ForEach(recent, id: \.self) { text in
                Button {
                    router.searchQuery = text
                } label: {
                    Label(text, systemImage: "clock.arrow.circlepath")
                        .tychoFont(.xs)
                        .padding(.horizontal, Spacing.s2)
                        .padding(.vertical, 2)
                        .background(Token.surface2.color, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var noResults: some View {
        ContentUnavailableView {
            Label("No results found", systemImage: "magnifyingglass")
        } description: {
            Text("Nothing matches “\(query)”. Check the spelling or try a broader term.")
        } actions: {
            Button("Clear search") { router.searchQuery = "" }
                .accessibilityIdentifier("search.clear")
        }
        .foregroundStyle(Token.text3.color)
    }

    private func refresh() {
        results = (try? SearchIndex.search(query, in: context)) ?? SearchResults()
    }
}
