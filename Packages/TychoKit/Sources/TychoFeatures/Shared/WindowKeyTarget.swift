import SwiftUI

enum KeyWindowScope {
    static func shouldHandle(eventWindow: AnyObject?, targetWindow: AnyObject?, isKey: Bool, hasSheet: Bool) -> Bool {
        guard let targetWindow, let eventWindow else { return false }
        return eventWindow === targetWindow && isKey && !hasSheet
    }
}

#if os(macOS)
import AppKit

@MainActor
final class WindowKeyTarget {
    var handle: ((NSEvent, NSWindow) -> Bool)?
    private(set) weak var window: NSWindow?
    private var monitor: Any?
    private var closeObserver: NSObjectProtocol?

    func attach(to window: NSWindow?) {
        guard window !== self.window else { return }
        stopObservingClose()
        self.window = window
        guard let window else { return remove() }
        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification, object: window, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.remove() }
        }
    }

    func install() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let consumed = MainActor.assumeIsolated { self?.consumes(event) ?? false }
            return consumed ? nil : event
        }
    }

    func remove() {
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    isolated deinit {
        remove()
        stopObservingClose()
    }

    private func consumes(_ event: NSEvent) -> Bool {
        guard let window,
            KeyWindowScope.shouldHandle(
                eventWindow: event.window, targetWindow: window, isKey: window.isKeyWindow,
                hasSheet: window.attachedSheet != nil),
            event.modifierFlags.isDisjoint(with: [.command, .option, .control])
        else { return false }
        return handle?(event, window) ?? false
    }

    private func stopObservingClose() {
        guard let closeObserver else { return }
        NotificationCenter.default.removeObserver(closeObserver)
        self.closeObserver = nil
    }
}

struct WindowKeyMonitor: ViewModifier {
    let handle: (NSEvent, NSWindow) -> Bool
    @State private var target = WindowKeyTarget()

    func body(content: Content) -> some View {
        target.handle = handle
        return
            content
            .background(WindowReader { target.attach(to: $0) })
            .onAppear { target.install() }
            .onDisappear { target.remove() }
    }
}

struct WindowReader: NSViewRepresentable {
    let onWindow: @MainActor (NSWindow?) -> Void

    func makeNSView(context: Context) -> WindowReportingView {
        let view = WindowReportingView()
        view.onWindow = onWindow
        return view
    }

    func updateNSView(_ view: WindowReportingView, context: Context) {
        view.onWindow = onWindow
    }

    final class WindowReportingView: NSView {
        var onWindow: (@MainActor (NSWindow?) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            onWindow?(window)
        }
    }
}
#endif
