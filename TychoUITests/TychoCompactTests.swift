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
            XCTAssertTrue(app.navigationBars[detour].waitForExistence(timeout: 3), "\(detour) did not open")
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

    func testTheNavigationBarHasNoPaletteButton() {
        openProject("Website Redesign")
        XCTAssertTrue(app.buttons["project.tab"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["toolbar.palette"].exists)
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

    func testMyTasksSearchFilterAndOptionsSitInTheBottomBar() {
        openProject("My Tasks")
        let controls = [app.buttons["Filter"], app.searchFields.firstMatch, app.buttons["View Options"]]
        XCTAssertTrue(controls[0].waitForExistence(timeout: 5))
        let bottom = app.windows.firstMatch.frame.height * 0.8
        for control in controls {
            XCTAssertTrue(control.exists)
            XCTAssertGreaterThan(control.frame.midY, bottom)
        }
    }

    func testSidebarSettingsLivesInTheNavigationBar() {
        let back = app.navigationBars.buttons["BackButton"]
        if back.waitForExistence(timeout: 3) { back.tap() }
        let settings = app.navigationBars["Tycho"].buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
    }
}
#endif
