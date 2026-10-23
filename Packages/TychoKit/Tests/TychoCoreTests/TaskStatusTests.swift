import Testing

@testable import TychoCore

struct TaskStatusTests {
    @Test func ordersStatusesLikeTheOriginal() {
        #expect(TaskStatus.allCases == [.backlog, .todo, .progress, .review, .done])
    }

    @Test(arguments: [
        (TaskStatus.backlog, "Backlog", 0),
        (.todo, "To Do", 5),
        (.progress, "In Progress", 45),
        (.review, "Review", 80),
        (.done, "Done", 100),
    ])
    func titlesAndBaselineProgress(status: TaskStatus, title: String, progress: Int) {
        #expect(status.title == title)
        #expect(status.baselineProgress == progress)
        #expect(TaskStatus(rawValue: status.rawValue) == status)
    }
}
