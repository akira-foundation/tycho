import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct UITestingDefaultsTests {
    private func makeDefaults() throws -> (UserDefaults, String) {
        let suite = "ui-testing-defaults-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.set(Data("{}".utf8), forKey: TaskViewStates.storageKey)
        defaults.set(["query"], forKey: RecentSearches.key)
        defaults.set("dark", forKey: AppearanceKey.theme)
        defaults.set("0 0 800 600", forKey: "NSWindow Frame Main")
        return (defaults, suite)
    }

    @Test func uiTestingLaunchClearsTheStoredPreferencesButKeepsWindowFrames() throws {
        let (defaults, suite) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }

        UITestingDefaults.resetIfTesting(arguments: ["Tycho", "-uiTesting"], defaults: defaults, domain: suite)

        #expect(defaults.data(forKey: TaskViewStates.storageKey) == nil)
        #expect(defaults.stringArray(forKey: RecentSearches.key) == nil)
        #expect(defaults.string(forKey: AppearanceKey.theme) == nil)
        #expect(defaults.string(forKey: "NSWindow Frame Main") == "0 0 800 600")
    }

    @Test func normalLaunchKeepsTheStoredPreferences() throws {
        let (defaults, suite) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }

        UITestingDefaults.resetIfTesting(arguments: ["Tycho"], defaults: defaults, domain: suite)

        #expect(defaults.data(forKey: TaskViewStates.storageKey) != nil)
        #expect(defaults.stringArray(forKey: RecentSearches.key) == ["query"])
        #expect(defaults.string(forKey: AppearanceKey.theme) == "dark")
    }
}
