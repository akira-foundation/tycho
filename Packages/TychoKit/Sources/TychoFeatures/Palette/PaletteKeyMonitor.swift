import SwiftUI

#if os(macOS)
import AppKit

@MainActor
final class PaletteKeyTarget {
    var handle: ((KeyEquivalent) -> KeyPress.Result)?
    var monitor: Any?
}

struct PaletteKeyMonitor: ViewModifier {
    let handle: (KeyEquivalent) -> KeyPress.Result
    @State private var target = PaletteKeyTarget()

    func body(content: Content) -> some View {
        target.handle = handle
        return
            content
            .onAppear { install() }
            .onDisappear { remove() }
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

    private func install() {
        guard target.monitor == nil else { return }
        let target = target
        target.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.isDisjoint(with: [.command, .option, .control]),
                let key = Self.key(forKeyCode: event.keyCode)
            else { return event }
            let result = MainActor.assumeIsolated { target.handle?(key) ?? .ignored }
            return result == .handled ? nil : event
        }
    }

    private func remove() {
        guard let monitor = target.monitor else { return }
        NSEvent.removeMonitor(monitor)
        target.monitor = nil
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
