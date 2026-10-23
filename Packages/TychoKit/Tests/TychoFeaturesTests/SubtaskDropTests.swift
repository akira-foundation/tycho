import Testing

@testable import TychoFeatures

struct SubtaskDropTests {
    private func apply(moving: Int, onto target: Int) -> [String] {
        var items = ["A", "B", "C"]
        let moved = items.remove(at: moving)
        let index = SubtaskList.dropIndex(moving: moving, onto: target)
        items.insert(moved, at: index)
        return items
    }

    @Test func movingDownReachesTheLastPosition() {
        #expect(apply(moving: 0, onto: 2) == ["B", "C", "A"])
        #expect(apply(moving: 1, onto: 2) == ["A", "C", "B"])
        #expect(apply(moving: 0, onto: 1) == ["B", "A", "C"])
    }

    @Test func movingUpLandsBeforeTheTarget() {
        #expect(apply(moving: 2, onto: 0) == ["C", "A", "B"])
        #expect(apply(moving: 2, onto: 1) == ["A", "C", "B"])
    }
}
