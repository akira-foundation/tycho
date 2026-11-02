import SwiftUI

#if os(macOS)
import AppKit
#endif

enum UITestingWindow {
    static let size = CGSize(width: 1100, height: 730)

    static func frame(in visible: CGRect) -> CGRect {
        let width = min(size.width, visible.width)
        let height = min(size.height, visible.height)
        return CGRect(x: visible.midX - width / 2, y: visible.midY - height / 2, width: width, height: height)
    }

    #if os(macOS)
    @MainActor static func stopAutosave(in window: NSWindow) {
        window.isRestorable = false
        window.setFrameAutosaveName("")
        guard let root = window.contentView else { return }
        for splitView in splitViews(under: root) {
            splitView.autosaveName = nil
        }
    }

    @MainActor static func splitViews(under view: NSView) -> [NSSplitView] {
        let own = (view as? NSSplitView).map { [$0] } ?? []
        return own + view.subviews.flatMap { splitViews(under: $0) }
    }
    #endif
}

extension View {
    func uiTestingWindowSize(_ isTesting: Bool) -> some View {
        #if os(macOS)
        background(
            WindowReader { window in
                guard isTesting, let window else { return }
                UITestingWindow.stopAutosave(in: window)
                Task { @MainActor in
                    let widest = NSScreen.screens.max { $0.visibleFrame.width < $1.visibleFrame.width }
                    guard let visible = widest?.visibleFrame else { return }
                    window.setFrame(UITestingWindow.frame(in: visible), display: true)
                }
            })
        #else
        self
        #endif
    }

    func uiTestingSplitViewAutosaveOff(_ isTesting: Bool) -> some View {
        #if os(macOS)
        background(
            WindowReader { window in
                guard isTesting, let window else { return }
                UITestingWindow.stopAutosave(in: window)
                Task { @MainActor in UITestingWindow.stopAutosave(in: window) }
            })
        #else
        self
        #endif
    }
}
