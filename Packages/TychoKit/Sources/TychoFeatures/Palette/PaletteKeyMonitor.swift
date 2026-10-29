import SwiftUI

enum PaletteKeyScope {
    static func shouldHandle(eventWindow: AnyObject?, paletteWindow: AnyObject?, isKey: Bool, hasSheet: Bool) -> Bool {
        guard let paletteWindow, let eventWindow else { return false }
        return eventWindow === paletteWindow && isKey && !hasSheet
    }
}

#if os(macOS)
import AppKit

@MainActor
final class PaletteKeyTarget {
    var handle: ((KeyEquivalent) -> KeyPress.Result)?
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
        let inScope = PaletteKeyScope.shouldHandle(
            eventWindow: event.window, paletteWindow: window, isKey: window?.isKeyWindow ?? false,
            hasSheet: window?.attachedSheet != nil)
        guard inScope, event.modifierFlags.isDisjoint(with: [.command, .option, .control]),
            let key = PaletteKeyMonitor.key(forKeyCode: event.keyCode)
        else { return false }
        return handle?(key) == .handled
    }

    private func stopObservingClose() {
        guard let closeObserver else { return }
        NotificationCenter.default.removeObserver(closeObserver)
        self.closeObserver = nil
    }
}

struct PaletteKeyMonitor: ViewModifier {
    let handle: (KeyEquivalent) -> KeyPress.Result
    @State private var target = PaletteKeyTarget()

    func body(content: Content) -> some View {
        target.handle = handle
        return
            content
            .background(PaletteWindowReader { target.attach(to: $0) })
            .onAppear { target.install() }
            .onDisappear { target.remove() }
    }

    static func key(forKeyCode keyCode: UInt16) -> KeyEquivalent? {
        switch keyCode {
        case 125: .downArrow
        case 126: .upArrow
        case 48: .tab
        case 53: .escape
        case 51: .delete
        default: nil
        }
    }
}

struct PaletteWindowReader: NSViewRepresentable {
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

extension View {
    func paletteKeyMonitor(_ handle: @escaping (KeyEquivalent) -> KeyPress.Result) -> some View {
        #if os(macOS)
        modifier(PaletteKeyMonitor(handle: handle))
        #else
        self
        #endif
    }
}
