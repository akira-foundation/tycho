#if os(iOS)
import XCTest

@MainActor
final class TychoCompactTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .phone, "compact width needs an iPhone")
        app.launch()
        let demo = app.buttons["onboarding.demo"]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        demo.tap()
    }

    private func openProject(_ name: String) {
        let title = app.navigationBars[name]
        for detour in ["Mobile App", name] where !title.exists {
            let back = app.navigationBars.buttons["BackButton"]
            if back.waitForExistence(timeout: 2) { back.tap() }
            let row = app.collectionViews.staticTexts[detour].firstMatch
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
            _ = app.navigationBars[detour].waitForExistence(timeout: 3)
        }
        XCTAssertTrue(title.waitForExistence(timeout: 3), "\(name) did not open")
    }

    func testProjectViewPickerNamesTheCurrentViewAndSwitches() {
        openProject("Website Redesign")
        let picker = app.buttons["project.tab"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        XCTAssertEqual(picker.label, "Board")

        picker.tap()
        app.buttons["Table"].firstMatch.tap()

        XCTAssertTrue(eventually { picker.label == "Table" })
    }

    func testPaletteButtonSitsWithTheTrailingToolbarItems() {
        openProject("Website Redesign")
        let picker = app.buttons["project.tab"]
        let palette = app.buttons["toolbar.palette"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        XCTAssertTrue(palette.waitForExistence(timeout: 5))

        XCTAssertGreaterThan(palette.frame.minX, picker.frame.maxX)
    }

    func testNewTaskSheetCancelsFromTheNavigationBar() {
        openProject("Website Redesign")
        app.buttons["New Task"].firstMatch.tap()
        let sheetBar = app.navigationBars["New task"]
        XCTAssertTrue(sheetBar.waitForExistence(timeout: 5))
        XCTAssertTrue(sheetBar.buttons["task.create"].exists)

        sheetBar.buttons["Cancel"].tap()

        XCTAssertTrue(eventually { !sheetBar.exists })
    }

    func testSidebarSettingsLivesInTheNavigationBar() {
        let back = app.navigationBars.buttons["BackButton"]
        if back.waitForExistence(timeout: 3) { back.tap() }
        let settings = app.navigationBars["Tycho"].buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
    }
}
#endif
