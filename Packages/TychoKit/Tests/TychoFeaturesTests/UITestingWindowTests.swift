import CoreGraphics
import Testing

@testable import TychoFeatures

#if os(macOS)
import AppKit
#endif

@MainActor
struct UITestingWindowTests {
    @Test func frameIsCentredInTheVisibleArea() {
        let frame = UITestingWindow.frame(in: CGRect(x: 0, y: 25, width: 1728, height: 1084))

        #expect(frame.size == UITestingWindow.size)
        #expect(frame.midX == 864)
        #expect(frame.midY == 567)
    }

    @Test func frameShrinksToASmallScreen() {
        let visible = CGRect(x: 0, y: 0, width: 1024, height: 700)

        let frame = UITestingWindow.frame(in: visible)

        #expect(frame == visible)
    }

    #if os(macOS)
    @Test func stoppingAutosaveKeepsWindowAndSplitFramesOutOfTheDefaults() {
        let name = "tycho-ui-testing-\(UUID().uuidString)"
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400), styleMask: [.titled, .resizable],
            backing: .buffered, defer: true)
        let splitView = NSSplitView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        splitView.addArrangedSubview(NSView())
        splitView.addArrangedSubview(NSView())
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        window.contentView?.addSubview(splitView)
        window.setFrameAutosaveName(name)
        splitView.autosaveName = name
        defer {
            UserDefaults.standard.removeObject(forKey: "NSWindow Frame \(name)")
            UserDefaults.standard.removeObject(forKey: "NSSplitView Subview Frames \(name)")
        }

        UITestingWindow.stopAutosave(in: window)
        window.setFrame(NSRect(x: 10, y: 10, width: 700, height: 500), display: false)
        splitView.setPosition(200, ofDividerAt: 0)

        #expect(window.frameAutosaveName.isEmpty)
        #expect(splitView.autosaveName == nil)
        #expect(!window.isRestorable)
        #expect(UserDefaults.standard.object(forKey: "NSWindow Frame \(name)") == nil)
        #expect(UserDefaults.standard.object(forKey: "NSSplitView Subview Frames \(name)") == nil)
    }
    #endif
}
