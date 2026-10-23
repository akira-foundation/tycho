import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct HomeTests {
    @Test(arguments: [
        (0, "Good morning"), (11, "Good morning"), (12, "Good afternoon"),
        (17, "Good afternoon"), (18, "Good evening"), (23, "Good evening"),
    ])
    func greetingFollowsTheHour(hour: Int, text: String) {
        #expect(Greeting.text(hour: hour) == text)
    }

    @Test func tabsShowAtMostSevenTasks() {
        let me = Member(name: "Me", email: "", isMe: true)
        let tasks = (1...10).map { index -> TaskItem in
            let task = TaskItem(number: index, title: "T\(index)")
            task.assignee = me
            return task
        }
        let summary = HomeSummary(projects: [], tasks: tasks, now: .now, calendar: .current)
        #expect(HomeTab.upcoming.tasks(in: summary).count == 7)
        #expect(HomeTab.allCases.map(\.title) == ["Upcoming", "Overdue", "Completed"])
    }
}
