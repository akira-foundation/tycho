import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskCardTests {
    @Test func summarisesSubtasks() {
        let task = TaskItem(number: 1, title: "x")
        #expect(TaskCard.subtaskSummary(task) == nil)
        task.subtasks = [Subtask(title: "a", isDone: true), Subtask(title: "b"), Subtask(title: "c", isDone: true)]
        #expect(TaskCard.subtaskSummary(task) == "2/3")
    }
}
