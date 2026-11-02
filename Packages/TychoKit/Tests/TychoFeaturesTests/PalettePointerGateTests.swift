import CoreGraphics
import Testing

@testable import TychoFeatures

@MainActor
struct PalettePointerGateTests {
    @Test func aRestingPointerDoesNotMoveTheHighlight() {
        var gate = PalettePointerGate(pointer: CGPoint(x: 10, y: 10))

        let admitted = gate.admits(CGPoint(x: 10, y: 10))

        #expect(!admitted)
    }

    @Test func aMovedPointerMovesTheHighlightOnce() {
        var gate = PalettePointerGate(pointer: CGPoint(x: 10, y: 10))

        let moved = gate.admits(CGPoint(x: 12, y: 40))
        let resting = gate.admits(CGPoint(x: 12, y: 40))

        #expect(moved)
        #expect(!resting)
    }

    @Test func withoutAPointerEveryHoverCounts() {
        var gate = PalettePointerGate(pointer: nil)

        let first = gate.admits(nil)
        let second = gate.admits(nil)

        #expect(first && second)
    }
}
