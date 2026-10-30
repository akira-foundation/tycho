import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct TychoDefaultsTests {
    @Test func uiTestingSelectsTheSeparateSuite() throws {
        let suite = "tycho-defaults-\(UUID().uuidString)"
        let testing = TychoDefaults.store(arguments: ["Tycho", "-uiTesting"], suite: suite)
        defer { testing.removePersistentDomain(forName: suite) }

        testing.set("dark", forKey: AppearanceKey.theme)

        #expect(testing !== UserDefaults.standard)
        #expect(UserDefaults(suiteName: suite)?.string(forKey: AppearanceKey.theme) == "dark")
    }

    @Test func aNormalLaunchUsesTheStandardDefaults() {
        #expect(TychoDefaults.store(arguments: ["Tycho"]) === UserDefaults.standard)
    }

    @Test func resettingClearsOnlyTheTestingSuite() throws {
        let suite = "tycho-defaults-\(UUID().uuidString)"
        let testing = try #require(UserDefaults(suiteName: suite))
        let standardKey = "tycho-defaults-standard-\(UUID().uuidString)"
        defer {
            testing.removePersistentDomain(forName: suite)
            UserDefaults.standard.removeObject(forKey: standardKey)
        }
        testing.set(["query"], forKey: RecentSearches.key)
        UserDefaults.standard.set("kept", forKey: standardKey)

        TychoDefaults.resetIfTesting(arguments: ["Tycho", "-uiTesting"], suite: suite)

        #expect(testing.stringArray(forKey: RecentSearches.key) == nil)
        #expect(UserDefaults.standard.string(forKey: standardKey) == "kept")
    }

    @Test func aNormalLaunchResetsNothing() throws {
        let suite = "tycho-defaults-\(UUID().uuidString)"
        let testing = try #require(UserDefaults(suiteName: suite))
        defer { testing.removePersistentDomain(forName: suite) }
        testing.set(["query"], forKey: RecentSearches.key)

        TychoDefaults.resetIfTesting(arguments: ["Tycho"], suite: suite)

        #expect(testing.stringArray(forKey: RecentSearches.key) == ["query"])
    }
}
