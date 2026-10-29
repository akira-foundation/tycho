import Foundation
import Testing

@testable import TychoFeatures

struct RecentSearchesTests {
    @Test func recentSearchesDeduplicateAndKeepFive() {
        var list: [String] = []
        for query in ["a", "b", "c", "d", "e", "f"] { list = RecentSearches.adding(query, to: list) }
        #expect(list == ["f", "e", "d", "c", "b"])
        #expect(RecentSearches.adding("c", to: list) == ["c", "f", "e", "d", "b"])
    }

    @Test func addingTrimsAndIgnoresEmpty() {
        #expect(RecentSearches.adding("  hello ", to: ["x"]) == ["hello", "x"])
        #expect(RecentSearches.adding("   ", to: ["x"]) == ["x"])
    }

    @Test func listRoundTripsThroughUserDefaults() throws {
        let suite = "recent-searches-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(RecentSearches.load(from: defaults).isEmpty)
        RecentSearches.save(["one", "two"], to: defaults)
        #expect(RecentSearches.load(from: defaults) == ["one", "two"])
        #expect(RecentSearches.key == "search.recent")
    }
}
