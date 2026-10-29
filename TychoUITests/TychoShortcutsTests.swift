#if os(macOS)
import XCTest

@MainActor
final class TychoShortcutsTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launchShowingWindow()
        app.loadDemoWorkspace()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
    }

    private func press(_ keys: String) {
        for key in keys { app.typeKey(String(key), modifierFlags: []) }
    }

    func testSingleKeysAndGSequencesOutsideFields() {
        XCTAssertTrue(element("toolbar.palette").waitForExistence(timeout: 5))
        press("gc")
        XCTAssertTrue(element("calendar.title").waitForExistence(timeout: 5))

        press("n")
        XCTAssertTrue(element("task.title").waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(element("task.title").waitForNonExistence(timeout: 5))

        press("/")
        XCTAssertTrue(element("palette.input").waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(element("palette.input").waitForNonExistence(timeout: 5))
    }

    func testShortcutKeysTypeIntoTheToolbarSearch() {
        app.openSidebarItem("Tasks", revealing: element("view.search"))
        let search = element("view.search")
        search.click()
        search.typeText("np/?[gc")
        XCTAssertEqual(search.value as? String, "np/?[gc")
        XCTAssertFalse(element("task.title").exists)
        XCTAssertFalse(element("project.name").exists)
        XCTAssertFalse(element("palette.input").exists)
        XCTAssertFalse(element("calendar.title").exists)
    }

    func testShortcutKeysTypeIntoThePalette() {
        XCTAssertTrue(element("toolbar.palette").waitForExistence(timeout: 5))
        app.typeKey("k", modifierFlags: .command)
        let input = element("palette.input")
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.typeText("gnp")
        XCTAssertEqual(input.value as? String, "gnp")
        XCTAssertFalse(element("task.title").exists)
        XCTAssertFalse(element("project.name").exists)
        app.typeKey("k", modifierFlags: .command)
        XCTAssertTrue(input.waitForNonExistence(timeout: 5))
    }
}
#endif
