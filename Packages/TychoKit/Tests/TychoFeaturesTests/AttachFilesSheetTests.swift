import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct AttachFilesSheetTests {
    @Test func candidatesAreTheProjectTasksInNumberOrder() {
        let project = Project(key: "WEB", name: "Website")
        project.tasks = [3, 1, 2].map { TaskItem(number: $0, title: "Task \($0)") }
        #expect(AttachFilesSheet.candidates(in: project).map(\.number) == [1, 2, 3])
    }

    @Test func noProjectOffersNoTasks() {
        #expect(AttachFilesSheet.candidates(in: nil).isEmpty)
    }
}
