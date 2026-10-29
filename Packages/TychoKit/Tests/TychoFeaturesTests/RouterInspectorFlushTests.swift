import Foundation
import Testing

@testable import TychoFeatures

@MainActor
struct RouterInspectorFlushTests {
    private final class FlushCounter {
        var count = 0
    }

    private func routerCountingFlushes() -> (Router, FlushCounter) {
        let router = Router()
        let counter = FlushCounter()
        router.registerInspectorFlush(UUID()) { counter.count += 1 }
        return (router, counter)
    }

    @Test func inspectingTheSameTaskAgainDoesNotFlush() {
        let (router, counter) = routerCountingFlushes()
        let id = UUID()
        router.inspect(id)
        let afterOpening = counter.count
        router.inspect(id)
        #expect(counter.count == afterOpening)
    }

    @Test func switchingToAnotherTaskFlushesOnce() {
        let (router, counter) = routerCountingFlushes()
        router.inspect(UUID())
        let afterOpening = counter.count
        router.inspect(UUID())
        #expect(counter.count == afterOpening + 1)
    }

    @Test func closingTheInspectorFlushes() {
        let (router, counter) = routerCountingFlushes()
        router.inspect(UUID())
        let afterOpening = counter.count
        router.closeInspector()
        #expect(counter.count == afterOpening + 1)
    }

    @Test func resizingWithinTheSameLayoutDoesNotFlush() {
        let (router, counter) = routerCountingFlushes()
        router.updateWindowWidth(900)
        router.updateWindowWidth(950)
        router.updateWindowWidth(1000)
        #expect(counter.count == 1)
    }

    @Test func crossingTheLayoutThresholdFlushesEachTime() {
        let (router, counter) = routerCountingFlushes()
        router.updateWindowWidth(900)
        router.updateWindowWidth(InspectorLayout.minimumWindowWidth)
        router.updateWindowWidth(900)
        #expect(counter.count == 3)
    }

    @Test func crossingTheSizeClassFlushesEachTime() {
        let (router, counter) = routerCountingFlushes()
        router.updateHorizontalSizeClass(isCompact: true)
        router.updateHorizontalSizeClass(isCompact: true)
        router.updateHorizontalSizeClass(isCompact: false)
        #expect(counter.count == 2)
    }

    @Test func releasingFlushesOnceAndEmptiesTheRegistry() {
        let (router, counter) = routerCountingFlushes()
        router.releaseInspectorFlushes()
        router.flushInspectorEdits()
        #expect(counter.count == 1)
        #expect(router.liveInspectorFlushCount == 0)
    }
}
