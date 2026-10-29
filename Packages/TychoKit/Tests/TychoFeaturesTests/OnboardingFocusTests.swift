#if os(macOS)
import AppKit
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct OnboardingFocusTests {
    @Test func nameFieldIsNotEditingWhenTheWindowOpens() throws {
        let container = try TychoSchema.makeContainer(inMemory: true)
        let host = NSHostingController(
            rootView: OnboardingView().environment(ToastCenter()).modelContainer(container))
        let window = NSWindow(contentViewController: host)
        window.setContentSize(NSSize(width: 1100, height: 730))
        window.makeKeyAndOrderFront(nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        defer { window.orderOut(nil) }

        #expect(!(window.firstResponder is NSText))
    }
}
#endif
