import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct TychoDefaultsTests {
    @Test func uiTestingSelectsTheSeparateSuite() throws {
        let scratch = try ScratchDefaults(name: "defaults.select")
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

    @Test func aTestingLaunchClearsOnlyTheTestingSuite() throws {
        let scratch = try ScratchDefaults(name: "defaults.reset")
        let real = try ScratchDefaults(name: "defaults.reset.real")
        defer {
            scratch.remove()
            real.remove()
        }
        scratch.defaults.set(["query"], forKey: RecentSearches.key)
        real.defaults.set("kept", forKey: AppearanceKey.theme)

        TychoDefaults.prepareLaunch(arguments: ["Tycho", "-uiTesting"], suite: scratch.suite, real: real.defaults)

        #expect(scratch.defaults.stringArray(forKey: RecentSearches.key) == nil)
        #expect(real.defaults.string(forKey: AppearanceKey.theme) == "kept")
    }

    @Test func aTestingLaunchKeepsTheRealFramesThroughTheReset() throws {
        let scratch = try ScratchDefaults(name: "defaults.frames")
        let real = try ScratchDefaults(name: "defaults.frames.real")
        let key = "NSWindow Frame tycho-defaults-test"
        defer {
            scratch.remove()
            real.remove()
        }
        real.defaults.set("414 339 900 450 0 0 1728 1084 ", forKey: key)

        TychoDefaults.prepareLaunch(arguments: ["Tycho", "-uiTesting"], suite: scratch.suite, real: real.defaults)
        real.defaults.set("314 177 1100 730 0 0 1728 1084 ", forKey: key)
        TychoDefaults.prepareLaunch(arguments: ["Tycho", "-uiTesting"], suite: scratch.suite, real: real.defaults)
        TychoDefaults.prepareLaunch(arguments: ["Tycho"], suite: scratch.suite, real: real.defaults)

        #expect(real.defaults.string(forKey: key) == "414 339 900 450 0 0 1728 1084 ")
    }

    @Test func aNormalLaunchResetsNothing() throws {
        let scratch = try ScratchDefaults(name: "defaults.normal-reset")
        let real = try ScratchDefaults(name: "defaults.normal-reset.real")
        defer {
            scratch.remove()
            real.remove()
        }
        scratch.defaults.set(["query"], forKey: RecentSearches.key)

        TychoDefaults.prepareLaunch(arguments: ["Tycho"], suite: scratch.suite, real: real.defaults)

        #expect(scratch.defaults.stringArray(forKey: RecentSearches.key) == ["query"])
    }
}
