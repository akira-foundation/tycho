import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct DependencyPickerTests {
    @Test func summaryJoinsKeys() {
        let project = Project(key: "WEB", name: "Web")
        let first = TaskItem(number: 3, title: "a")
        let second = TaskItem(number: 7, title: "b")
        first.project = project
        second.project = project
        #expect(DependencyPicker.summary(of: [first, second]) == "WEB-3, WEB-7")
        #expect(DependencyPicker.summary(of: []).isEmpty)
    }
}
