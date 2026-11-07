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
        XCTAssertTrue(projectName.waitForNonExistence(timeout: 5))
        app.typeKey("n", modifierFlags: .command)
        let taskTitle = element("task.title")
        XCTAssertTrue(taskTitle.waitForExistence(timeout: 5))
        taskTitle.click()
        taskTitle.typeText("First task")
        element("task.create").click()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
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
        app.openWebsiteTab("List")
        let title = openInspector(from: element("task.WEB-118"))
        XCTAssertEqual(element("inspector.close").label, "Done")
        mouseClick("inspector.close")

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }

    private func typeUnsavedNotes(_ notes: String) {
        mouseClick("inspector.notes.edit")
        let editor = element("inspector.notes.editor")
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.click()
        editor.typeText(notes)
    }

    private func reopenedNotesShow(_ notes: String) -> Bool {
        _ = openInspector(from: element("task.WEB-118"))
        return app.staticTexts[notes].firstMatch.waitForExistence(timeout: 5)
    }

    func testUnsavedNotesSurviveClosingTheInspector() {
        loadDemo()
        app.openWebsiteTab("List")
        _ = openInspector(from: element("task.WEB-118"))
        typeUnsavedNotes("Unsaved notes")

        mouseClick("inspector.close")

        XCTAssertTrue(reopenedNotesShow("Unsaved notes"))
    }

    func testUnsavedNotesInTheColumnSurviveClosingTheWindow() {
        loadDemo()
        app.zoomWindow()
        app.openWebsiteTab("List")
        _ = openInspector(from: element("task.WEB-118"))
        XCTAssertTrue(app.sheets.count == 0, "the inspector should be a column in a zoomed window")
        XCTAssertEqual(element("inspector.close").label, "Close")
        typeUnsavedNotes("Unsaved notes")

        app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()
        XCTAssertTrue(app.windows.firstMatch.waitForNonExistence(timeout: 5))
        app.reopenWindow()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 10))
        app.openWebsiteTab("List")

        XCTAssertTrue(reopenedNotesShow("Unsaved notes"))
    }

    func testUnsavedNotesSurviveOpeningANewTask() {
        loadDemo()
        app.openWebsiteTab("List")
        _ = openInspector(from: element("task.WEB-118"))
        typeUnsavedNotes("Unsaved notes")

        app.typeKey("n", modifierFlags: .command)
        XCTAssertTrue(element("task.title").waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])

        XCTAssertTrue(reopenedNotesShow("Unsaved notes"))
    }

    func testCloseButtonDismissesTheInspectorOpenedFromTheTable() {
        loadDemo()
        app.openWebsiteTab("Table")
        let title = openInspector(from: element("table.title.WEB-118"))
        mouseClick("inspector.close")

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }

    func testHeaderButtonsRespondToTheMouseInTheTable() {
        loadDemo()
        app.openWebsiteTab("Table")
        _ = openInspector(from: element("table.title.WEB-118"))
        let favorite = app.buttons["inspector.favorite"].firstMatch
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        let before = favorite.label
        mouseClick("inspector.favorite")

        XCTAssertTrue(favorite.waitForLabelChange(from: before))
    }

    func testSheetActionsCompleteAndOfferDelete() {
        loadDemo()
        app.openWebsiteTab("Table")
        _ = openInspector(from: element("table.title.WEB-118"))
        let complete = app.buttons["inspector.complete"].firstMatch
        XCTAssertTrue(complete.waitForExistence(timeout: 5))
        let before = complete.label
        mouseClick("inspector.complete")
        XCTAssertTrue(complete.waitForLabelChange(from: before))

        let more = app.descendants(matching: .any)["inspector.more"].firstMatch
        XCTAssertTrue(more.waitForExistence(timeout: 5))
        more.click()
        XCTAssertTrue(app.menuItems["inspector.delete"].firstMatch.waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])
    }

    func testCloseButtonDismissesTheInspectorInANewWorkspaceTable() {
        startEmptyWithOneTask()
        app.openProjectTab("Table")
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
