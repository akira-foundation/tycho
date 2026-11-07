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
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
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

    func testPOpensNewProjectAndBracketTogglesTheSidebarOutsideFields() {
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
        press("p")
        XCTAssertTrue(element("project.name").waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(element("project.name").waitForNonExistence(timeout: 5))

        let outline = app.outlines.firstMatch
        XCTAssertTrue(outline.waitForExistence(timeout: 5))
        let shown = outline.frame
        press("[")
        XCTAssertTrue(eventually { !outline.exists || outline.frame != shown }, "[ should hide the sidebar")
        press("[")
        XCTAssertTrue(eventually { outline.exists && outline.frame == shown }, "[ should show the sidebar again")
    }

    func testCommandKStaysOffWhileEditProjectIsOpen() throws {
        let widest = NSScreen.screens.map(\.visibleFrame.width).max() ?? 0
        try XCTSkipUnless(widest >= 1500, "Edit Project needs a zoomed window at least 1500 pt wide")
        app.zoomWindow()
        app.openSidebarItem("Website Redesign", revealing: element("project.tab"))
        app.buttons["Edit Project"].firstMatch.click()
        let name = element("project.name")
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        app.typeKey("k", modifierFlags: .command)
        XCTAssertFalse(element("palette.input").waitForExistence(timeout: 1), "the palette should stay closed")

        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(name.waitForNonExistence(timeout: 5))
        app.typeKey("k", modifierFlags: .command)
        XCTAssertTrue(element("palette.input").waitForExistence(timeout: 5), "the palette should open again")
    }

    func testShortcutKeysTypeIntoTheToolbarSearch() {
        let search = app.searchFields.firstMatch
        app.openSidebarItem("Tasks", revealing: search)
        let sidebar = app.outlines.firstMatch.frame
        search.click()
        search.typeText("np/?[gc")
        XCTAssertEqual(search.value as? String, "np/?[gc")
        XCTAssertFalse(element("shortcuts.sheet").waitForExistence(timeout: 1))
        XCTAssertFalse(element("calendar.title").waitForExistence(timeout: 1))
        XCTAssertEqual(app.outlines.firstMatch.frame, sidebar, "[ should not toggle the sidebar")
        XCTAssertFalse(element("task.title").exists)
        XCTAssertFalse(element("project.name").exists)
        XCTAssertFalse(element("palette.input").exists)
    }

    func testShortcutKeysTypeIntoThePalette() {
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
        let outline = app.outlines.firstMatch
        XCTAssertTrue(outline.waitForExistence(timeout: 5))
        let sidebar = outline.frame
        app.typeKey("k", modifierFlags: .command)
        let input = element("palette.input")
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.typeText("np/?[g")
        XCTAssertEqual(input.value as? String, "np/?[g")
        XCTAssertFalse(element("shortcuts.sheet").waitForExistence(timeout: 1))
        XCTAssertFalse(element("task.title").exists)
        XCTAssertFalse(element("project.name").exists)
        app.typeKey("k", modifierFlags: .command)
        XCTAssertTrue(input.waitForNonExistence(timeout: 5))
        XCTAssertTrue(outline.waitForExistence(timeout: 5), "[ should not hide the sidebar")
        XCTAssertEqual(outline.frame, sidebar, "[ should not toggle the sidebar")
    }

    func testQuestionMarkShowsShortcutsAndGThenCOpensCalendar() {
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
        press("?")
        let sheet = element("shortcuts.sheet")
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(sheet.waitForNonExistence(timeout: 5))

        press("gc")
        XCTAssertTrue(element("calendar.title").waitForExistence(timeout: 5))
    }

    func testDoneClosesTheShortcutsSheetAndSingleKeysStillWork() {
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
        press("?")
        let sheet = element("shortcuts.sheet")
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        app.sheets.buttons["Done"].firstMatch.click()
        XCTAssertTrue(sheet.waitForNonExistence(timeout: 5))

        press("n")
        XCTAssertTrue(element("task.title").waitForExistence(timeout: 5))
    }

    func testSettingsShowsTheShortcutsSection() {
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(element("settings.shortcuts").waitForExistence(timeout: 5))
    }
}
#endif
