import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ProjectSortTests {
    private func project(_ name: String, updated: Double, due: Double?, done: Int, total: Int) -> Project {
        let project = Project(key: "AA", name: name)
        project.updatedAt = Date(timeIntervalSince1970: updated)
        project.due = due.map(Date.init(timeIntervalSince1970:))
        project.tasks = (0..<total).map { index in
            let task = TaskItem(number: index, title: "t")
            task.status = index < done ? .done : .todo
            return task
        }
        return project
    }

    @Test func sortsLikeTheOriginalOptions() {
        let alpha = project("alpha", updated: 10, due: 300, done: 1, total: 4)
        let beta = project("Beta", updated: 30, due: nil, done: 3, total: 4)
        let gamma = project("gamma", updated: 20, due: 100, done: 0, total: 4)
        let all = [alpha, beta, gamma]

        #expect(ProjectSort.recent.sorted(all).map(\.name) == ["Beta", "gamma", "alpha"])
        #expect(ProjectSort.name.sorted(all).map(\.name) == ["alpha", "Beta", "gamma"])
        #expect(ProjectSort.due.sorted(all).map(\.name) == ["gamma", "alpha", "Beta"])
        #expect(ProjectSort.progress.sorted(all).map(\.name) == ["Beta", "alpha", "gamma"])
    }

    @Test(arguments: [
        ("Website Redesign", "WR"), ("Mobile", "MOB"), ("a b c d e f", "ABCDE"), ("  ", ""), ("3D Print Lab", "PL"),
    ])
    func suggestsAKeyFromTheName(name: String, key: String) {
        #expect(ProjectSymbols.suggestedKey(for: name) == key)
    }
}
