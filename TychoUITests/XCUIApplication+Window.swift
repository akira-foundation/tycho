import XCTest

#if os(macOS)
import AppKit
#endif

extension XCUIApplication {
    func launchShowingWindow() {
        launch()
        reopenWindow()
    }

    func reopenWindow() {
        #if os(macOS)
        let launched = NSRunningApplication.runningApplications(withBundleIdentifier: "io.akira.tycho")
            .max { ($0.launchDate ?? .distantPast) < ($1.launchDate ?? .distantPast) }
        guard let bundleURL = launched?.bundleURL else { return }
        NSWorkspace.shared.openApplication(at: bundleURL, configuration: NSWorkspace.OpenConfiguration())
        #endif
    }
}
