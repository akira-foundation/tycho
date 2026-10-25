#if os(macOS)
import XCTest

@MainActor
final class TychoInspectorTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
    }

    private func loadDemo() {
        app.launchShowingWindow()
        app.loadDemoWorkspace()
    }

    private func startEmptyWithOneTask() {
        app.launchShowingWindow()
        let name = app.textFields["onboarding.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.click()
        name.typeText("Kid")
        app.buttons["onboarding.empty"].click()
        app.buttons["New Project"].firstMatch.click()
        let projectName = element("project.name")
        XCTAssertTrue(projectName.waitForExistence(timeout: 5))
        projectName.click()
        projectName.typeText("Alpha")
        element("project.save").click()
        app.buttons["New Task"].firstMatch.click()
        let taskTitle = element("task.title")
        XCTAssertTrue(taskTitle.waitForExistence(timeout: 5))
        taskTitle.click()
        taskTitle.typeText("First task")
        element("task.create").click()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
    }

    private func openWebsiteTab(_ tab: String) {
        app.openSidebarItem("Website Redesign", revealing: element("project.tab"))
        openTab(tab)
    }

    private func openTab(_ tab: String) {
        let picker = element("project.tab")
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.descendants(matching: .any)[tab].firstMatch.click()
    }

    private func openInspector(from source: XCUIElement) -> XCUIElement {
        XCTAssertTrue(source.waitForExistence(timeout: 5))
        source.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5)).click()
        let title = app.textFields["inspector.title"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        return title
    }

    private func mouseClick(_ identifier: String) {
        let target = app.buttons[identifier].firstMatch
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).click()
    }

    func testCloseButtonDismissesTheInspectorOpenedFromTheList() {
        loadDemo()
        openWebsiteTab("List")
        let title = openInspector(from: element("task.WEB-118"))
        mouseClick("inspector.close")

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }

    func testCloseButtonDismissesTheInspectorOpenedFromTheTable() {
        loadDemo()
        openWebsiteTab("Table")
        let title = openInspector(from: element("table.title.WEB-118"))
        mouseClick("inspector.close")

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }

    func testHeaderButtonsRespondToTheMouseInTheTable() {
        loadDemo()
        openWebsiteTab("Table")
        _ = openInspector(from: element("table.title.WEB-118"))
        let favorite = app.buttons["inspector.favorite"].firstMatch
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        let before = favorite.label
        mouseClick("inspector.favorite")

        XCTAssertTrue(favorite.waitForLabelChange(from: before))
    }

    func testCloseButtonDismissesTheInspectorInANewWorkspaceTable() {
        startEmptyWithOneTask()
        openTab("Table")
        let row = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'table.title.'")
        ).firstMatch
        let title = openInspector(from: row)
        mouseClick("inspector.close")

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }
}

extension XCUIElement {
    fileprivate func waitForLabelChange(from label: String, timeout: TimeInterval = 5) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if self.label != label { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return self.label != label
    }
}
#endif
