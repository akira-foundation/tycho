import CoreGraphics

#if os(macOS)
import AppKit
#endif

struct PalettePointerGate {
    private var last: CGPoint?

    init(pointer: CGPoint?) {
        last = pointer
    }

    mutating func admits(_ pointer: CGPoint?) -> Bool {
        guard let pointer else { return true }
        defer { last = pointer }
        return pointer != last
    }

    @MainActor static var pointer: CGPoint? {
        #if os(macOS)
        NSEvent.mouseLocation
        #else
        nil
        #endif
    }
}
