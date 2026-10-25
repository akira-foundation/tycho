import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskGroupingTests {
    @Test func groupsByStatusInOrderAndSortsWithinGroups() {
        let a = TaskItem(number: 1, title: "a")
        a.status = .review
        a.sortOrder = 2
        let b = TaskItem(number: 2, title: "b")
        b.status = .review
        b.sortOrder = 1
        let c = TaskItem(number: 3, title: "c")
        c.status = .backlog

        let groups = TaskGrouping.byStatus([a, b, c])
        #expect(groups.map(\.status) == TaskStatus.allCases)
        #expect(groups[0].tasks.map(\.title) == ["c"])
        #expect(groups[3].tasks.map(\.title) == ["b", "a"])
        #expect(groups[4].tasks.isEmpty)
    }
}
