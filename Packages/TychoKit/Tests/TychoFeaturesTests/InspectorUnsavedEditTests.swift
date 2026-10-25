#if os(macOS)
import AppKit
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct InspectorUnsavedEditTests {
    @Test func unsavedTitleSurvivesNewTask() throws {
        let fixture = try InspectorHostFixture(width: 1000)
        try fixture.renameInSheet(to: "Unsaved title", submit: false)

        fixture.router.newTask()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Unsaved title")
        fixture.router.isCreatingTask = false
        fixture.window.orderOut(nil)
    }

    @Test func unsavedEstimateSurvivesNewProject() throws {
        let fixture = try InspectorHostFixture(width: 1000)
        let sheet = try #require(fixture.window.sheets.first)
        try fixture.type("3d", into: fixture.estimateField(in: sheet), submit: false)

        fixture.router.newProject()
        fixture.settle(1.5)

        #expect(fixture.task.estimate == "3d")
        fixture.router.isCreatingProject = false
        fixture.window.orderOut(nil)
    }

    @Test func unsavedTitleSurvivesWideningTheWindow() throws {
        let fixture = try InspectorHostFixture(width: 1000)
        try fixture.renameInSheet(to: "Unsaved title", submit: false)

        fixture.resize(to: 1500)

        #expect(fixture.task.title == "Unsaved title")
        fixture.router.closeInspector()
        fixture.settle(1.0)
        #expect(fixture.task.title == "Unsaved title")
        fixture.window.orderOut(nil)
    }

    @Test func unsavedTitleSurvivesClosingTheSheet() throws {
        let fixture = try InspectorHostFixture(width: 1000)
        try fixture.renameInSheet(to: "Unsaved title", submit: false)

        fixture.router.closeInspector()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Unsaved title")
        fixture.window.orderOut(nil)
    }

    @Test func reopeningAfterAnUnsavedCloseShowsTheSavedTitleAndAcceptsTyping() throws {
        let fixture = try InspectorHostFixture(width: 1000)
        try fixture.renameInSheet(to: "Unsaved title", submit: false)
        fixture.router.closeInspector()
        fixture.settle(3.0)

        fixture.router.inspect(fixture.task.id)
        fixture.settle(1.0)
        try fixture.renameInSheet(to: "Typed after reopening", submit: true)

        #expect(fixture.task.title == "Typed after reopening")
        fixture.window.orderOut(nil)
    }

    @Test(arguments: [1000.0, 1500.0])
    func unsavedTitleSurvivesTheWindowClosing(width: Double) throws {
        let fixture = try InspectorHostFixture(width: width)
        let root = fixture.window.sheets.first ?? fixture.window
        try fixture.type(
            "Unsaved title", into: fixture.titleField(in: root, current: fixture.task.title), submit: false)

        fixture.closeWindow()

        #expect(fixture.task.title == "Unsaved title")
    }

    @Test(arguments: [1000.0, 1500.0])
    func closingTheWindowReleasesEveryInspectorFlush(width: Double) throws {
        let fixture = try InspectorHostFixture(width: width)

        fixture.closeWindow()

        #expect(fixture.router.liveInspectorFlushCount == 0)
    }
}
#endif
