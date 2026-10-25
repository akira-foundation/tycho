import Testing

@testable import TychoCore

final class Box: Rankable {
    var sortOrder: Double
    init(_ order: Double) { sortOrder = order }
}

struct RankTests {
    @Test func midpointBetweenNeighbours() {
        #expect(Rank.between(1024, 2048) == 1536)
        #expect(Rank.between(nil, nil) == 1024)
        #expect(Rank.between(2048, nil) == 3072)
        #expect(Rank.between(nil, 1024) == 0)
    }

    @Test func refusesAGapBelowEpsilon() {
        #expect(Rank.between(1, 1 + 1e-7) == nil)
    }

    @Test func insertsBetweenSiblings() {
        let siblings = [Box(1024), Box(2048), Box(3072)]
        let moved = Box(9999)
        Rank.insert(moved, into: siblings, at: 1)
        #expect(moved.sortOrder == 1536)
    }

    @Test func clampsAnOutOfRangeIndexToTheEnd() {
        let siblings = [Box(1024)]
        let moved = Box(0)
        Rank.insert(moved, into: siblings, at: 7)
        #expect(moved.sortOrder == 2048)
    }

    @Test func repeatedInsertsIntoTheSameGapRenormaliseAndKeepOrder() {
        let first = Box(1024)
        let last = Box(2048)
        var ordered = [first, last]
        for _ in 0..<80 {
            let moved = Box(0)
            Rank.insert(moved, into: ordered, at: 1)
            ordered.insert(moved, at: 1)
        }
        let orders = ordered.map(\.sortOrder)
        #expect(orders == orders.sorted())
        #expect(Set(orders).count == orders.count)
        #expect(ordered.first === first)
        #expect(ordered.last === last)
    }

    @Test func appendOrderFollowsTheLargest() {
        #expect(Rank.appendOrder(after: [Box(10), Box(4000)]) == 5024)
        #expect(Rank.appendOrder(after: [Box]()) == 1024)
    }
}
