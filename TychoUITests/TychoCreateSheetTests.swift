#if os(macOS)
import XCTest

@MainActor
final class TychoCreateSheetTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launchShowingWindow()
        let name = app.textFields["onboarding.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.click()
        name.typeKey("a", modifierFlags: .command)
        name.typeText("Kid")
        app.buttons["onboarding.empty"].click()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
    }

    func testOptionReturnBreaksTheProjectDescriptionAndReturnCreatesTheProject() {
        app.buttons["New Project"].firstMatch.click()
        let name = element("project.name")
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertTrue(eventually { name.hasFocus }, "the name should take focus when the sheet opens")
        app.typeText("Beta")
        app.typeKey(.tab, modifierFlags: [])
        let summary = element("project.summary")
        XCTAssertTrue(eventually { summary.hasFocus }, "Tab should reach the description")
        app.typeText("First line")
        app.typeKey(.return, modifierFlags: .option)
        app.typeText("Second line")
        XCTAssertEqual(summary.value as? String, "First line\nSecond line")
        XCTAssertTrue(name.exists, "Option-Return should not create the project")

        app.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(name.waitForNonExistence(timeout: 5))
        XCTAssertTrue(element("project.tab").waitForExistence(timeout: 5))
    }

    func testEscapeCancelsTheNewProjectSheet() {
        app.buttons["New Project"].firstMatch.click()
        let name = element("project.name")
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        app.typeText("Gamma")
        app.typeKey(.escape, modifierFlags: [])

        XCTAssertTrue(name.waitForNonExistence(timeout: 5))
        XCTAssertFalse(app.outlines.staticTexts["Gamma"].exists)
    }
}
#endif
