import SwiftUI

enum PaletteKeyMonitor {
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

extension View {
    func paletteKeyMonitor(_ handle: @escaping (KeyEquivalent) -> KeyPress.Result) -> some View {
        #if os(macOS)
        modifier(
            WindowKeyMonitor { event, _ in
                guard let key = PaletteKeyMonitor.key(forKeyCode: event.keyCode) else { return false }
                return handle(key) == .handled
            })
        #else
        self
        #endif
    }
}
