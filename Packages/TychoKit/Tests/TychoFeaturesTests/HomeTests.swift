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
        let project = Project(key: "WEB", name: "Web")
        let tasks = (1...10).map { index -> TaskItem in
            let task = TaskItem(number: index, title: "T\(index)")
            task.assignee = me
            task.project = project
            return task
        }
        let summary = HomeSummary(projects: [project], tasks: tasks, now: .now, calendar: .current)
        #expect(HomeTab.upcoming.tasks(in: summary).count == 7)
        #expect(HomeTab.allCases.map(\.title) == ["Upcoming", "Overdue", "Completed"])
    }

    @Test(arguments: [("Kid", "Good morning, Kid · Saturday, November 7"), ("", "Good morning · Saturday, November 7")])
    func subtitleGreetsByNameAndShowsTheDate(name: String, expected: String) {
        var components = DateComponents(year: 2026, month: 11, day: 7, hour: 9)
        components.timeZone = DateText.gregorian.timeZone
        let now = DateText.gregorian.date(from: components)!
        #expect(HomeView.subtitle(name: name, now: now, dateText: DateText(now: now)) == expected)
    }
}
