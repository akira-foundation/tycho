import SwiftUI

enum UITestingWindow {
    static let size = CGSize(width: 1100, height: 730)

    static func frame(in visible: CGRect) -> CGRect {
        let width = min(size.width, visible.width)
        let height = min(size.height, visible.height)
        return CGRect(x: visible.midX - width / 2, y: visible.midY - height / 2, width: width, height: height)
    }
}

extension View {
    func uiTestingWindowSize(_ isTesting: Bool) -> some View {
        #if os(macOS)
        background(
            WindowReader { window in
                guard isTesting, let window else { return }
                window.isRestorable = false
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
}
