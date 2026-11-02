import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct WindowFramesTests {
    private let windowKey = "NSWindow Frame tycho-window-frames-test"
    private let splitKey = "NSSplitView Subview Frames tycho-window-frames-test"

    @Test func aTestingLaunchKeepsACopyOfTheRealFrames() throws {
        let real = try ScratchDefaults(name: "frames.preserve.real")
        let testing = try ScratchDefaults(name: "frames.preserve.testing")
        defer {
            real.remove()
            testing.remove()
        }
        real.defaults.set("414 339 900 450 0 0 1728 1084 ", forKey: windowKey)
        real.defaults.set(["0 0 220 450, NO, NO"], forKey: splitKey)
        real.defaults.set("dark", forKey: AppearanceKey.theme)

        WindowFrames.preserve(from: real.defaults, into: testing.defaults)

        let backup = testing.defaults.dictionary(forKey: WindowFrames.backupKey)
        #expect(backup?[windowKey] as? String == "414 339 900 450 0 0 1728 1084 ")
        #expect(backup?[splitKey] as? [String] == ["0 0 220 450, NO, NO"])
        #expect(backup?[AppearanceKey.theme] == nil)
    }

    @Test func aSecondTestingLaunchKeepsTheFirstCopy() throws {
        let real = try ScratchDefaults(name: "frames.second.real")
        let testing = try ScratchDefaults(name: "frames.second.testing")
        defer {
            real.remove()
            testing.remove()
        }
        real.defaults.set("414 339 900 450 0 0 1728 1084 ", forKey: windowKey)
        WindowFrames.preserve(from: real.defaults, into: testing.defaults)
        real.defaults.set("314 177 1100 730 0 0 1728 1084 ", forKey: windowKey)

        WindowFrames.preserve(from: real.defaults, into: testing.defaults)

        let backup = testing.defaults.dictionary(forKey: WindowFrames.backupKey)
        #expect(backup?[windowKey] as? String == "414 339 900 450 0 0 1728 1084 ")
    }

    @Test func aNormalLaunchPutsTheRealFramesBackAndDropsTheCopy() throws {
        let real = try ScratchDefaults(name: "frames.restore.real")
        let testing = try ScratchDefaults(name: "frames.restore.testing")
        defer {
            real.remove()
            testing.remove()
        }
        real.defaults.set("414 339 900 450 0 0 1728 1084 ", forKey: windowKey)
        WindowFrames.preserve(from: real.defaults, into: testing.defaults)
        real.defaults.set("314 177 1100 730 0 0 1728 1084 ", forKey: windowKey)
        real.defaults.set(["0 0 260 730, NO, NO"], forKey: splitKey)

        WindowFrames.restore(into: real.defaults, from: testing.defaults)

        #expect(real.defaults.string(forKey: windowKey) == "414 339 900 450 0 0 1728 1084 ")
        #expect(real.defaults.object(forKey: splitKey) == nil)
        #expect(testing.defaults.object(forKey: WindowFrames.backupKey) == nil)
    }

    @Test func aNormalLaunchWithoutACopyLeavesTheRealFramesAlone() throws {
        let real = try ScratchDefaults(name: "frames.nocopy.real")
        let testing = try ScratchDefaults(name: "frames.nocopy.testing")
        defer {
            real.remove()
            testing.remove()
        }
        real.defaults.set("414 339 900 450 0 0 1728 1084 ", forKey: windowKey)

        WindowFrames.restore(into: real.defaults, from: testing.defaults)

        #expect(real.defaults.string(forKey: windowKey) == "414 339 900 450 0 0 1728 1084 ")
    }
}
