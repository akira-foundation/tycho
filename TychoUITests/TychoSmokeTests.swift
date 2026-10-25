#if os(macOS)
import XCTest

@MainActor
final class TychoSmokeTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    func testDemoBoardMovesACardThroughTheContextMenu() {
        app.buttons["onboarding.demo"].click()
        app.outlines.staticTexts["Website Redesign"].firstMatch.click()

        let card = app.descendants(matching: .any)["card.WEB-124"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.rightClick()
        app.menuItems["Status"].firstMatch.click()
        app.menuItems["In Progress"].firstMatch.click()

        let progress = app.descendants(matching: .any)["column.progress"]
        let todo = app.descendants(matching: .any)["column.todo"]
        XCTAssertTrue(progress.descendants(matching: .any)["card.WEB-124"].waitForExistence(timeout: 5))
        XCTAssertFalse(todo.descendants(matching: .any)["card.WEB-124"].exists)
    }

    func testInspectorRejectsABlankTitle() {
        app.buttons["onboarding.demo"].click()
        app.outlines.staticTexts["Website Redesign"].firstMatch.click()
        app.descendants(matching: .any)["card.WEB-109"].click()

        let title = app.textFields["inspector.title"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.click()
        title.typeKey("a", modifierFlags: .command)
        title.typeText(" \r")

        XCTAssertTrue(app.staticTexts["Title can't be empty."].waitForExistence(timeout: 5))
    }

    func testInspectorCloseButtonDismissesThePanel() {
        app.buttons["onboarding.demo"].click()
        app.outlines.staticTexts["Website Redesign"].firstMatch.click()
        app.descendants(matching: .any)["card.WEB-109"].click()

        let title = app.textFields["inspector.title"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        app.buttons["inspector.close"].firstMatch.click()

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }
}
#endif
