import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct TychoDefaultsTests {
    @Test func uiTestingSelectsTheSeparateSuite() {
        let scratch = ScratchDefaults(name: "defaults.select")
        defer { scratch.remove() }
        let testing = TychoDefaults.store(arguments: ["Tycho", "-uiTesting"], suite: scratch.suite)

        testing.set("dark", forKey: AppearanceKey.theme)

        #expect(testing !== UserDefaults.standard)
        #expect(scratch.defaults.string(forKey: AppearanceKey.theme) == "dark")
    }

    @Test func aNormalLaunchUsesTheStandardDefaults() {
        #expect(TychoDefaults.store(arguments: ["Tycho"]) === UserDefaults.standard)
        #expect(!TychoDefaults.isUITesting(["Tycho"]))
        #expect(TychoDefaults.isUITesting(["Tycho", "-uiTesting"]))
    }

    @Test func resettingClearsOnlyTheTestingSuite() {
        let scratch = ScratchDefaults(name: "defaults.reset")
        let standardKey = "tycho-defaults-standard-\(UUID().uuidString)"
        defer {
            scratch.remove()
            UserDefaults.standard.removeObject(forKey: standardKey)
        }
        scratch.defaults.set(["query"], forKey: RecentSearches.key)
        UserDefaults.standard.set("kept", forKey: standardKey)

        TychoDefaults.resetIfTesting(arguments: ["Tycho", "-uiTesting"], suite: scratch.suite)

        #expect(scratch.defaults.stringArray(forKey: RecentSearches.key) == nil)
        #expect(UserDefaults.standard.string(forKey: standardKey) == "kept")
    }

    @Test func aNormalLaunchResetsNothing() {
        let scratch = ScratchDefaults(name: "defaults.normal-reset")
        defer { scratch.remove() }
        scratch.defaults.set(["query"], forKey: RecentSearches.key)

        TychoDefaults.resetIfTesting(arguments: ["Tycho"], suite: scratch.suite)

        #expect(scratch.defaults.stringArray(forKey: RecentSearches.key) == ["query"])
    }
}
