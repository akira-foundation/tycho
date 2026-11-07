import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ProjectDetailSubtitleTests {
    @Test func showsTheStatusAndProgress() {
        let project = Project(key: "AA", name: "Alpha")
        project.status = .risk
        project.tasks = (0..<4).map { index in
            let task = TaskItem(number: index, title: "t")
            task.status = index == 0 ? .done : .todo
            return task
        }

        #expect(ProjectDetailView.subtitle(project) == "At Risk · 25%")
    }
}
