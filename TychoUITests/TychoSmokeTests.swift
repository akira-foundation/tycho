#if os(macOS)
import XCTest

@MainActor
final class TychoSmokeTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launchShowingWindow()
    }

    private func openWebsiteBoard() {
        app.loadDemoWorkspace()
        app.openSidebarItem("Website Redesign", revealing: app.element("column.backlog"))
    }

    func testDemoBoardMovesACardThroughTheContextMenu() {
        openWebsiteBoard()

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

    private func openFirstBacklogCard() -> XCUIElement {
        openWebsiteBoard()
        let backlog = app.element("column.backlog")
        let firstCard = backlog.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'card.' AND NOT identifier ENDSWITH '.toggle'")
        ).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.click()

        let title = app.textFields["inspector.title"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        return title
    }

    func testInspectorRejectsABlankTitle() {
        let title = openFirstBacklogCard()
        title.click()
        title.typeKey("a", modifierFlags: .command)
        title.typeText(" \r")

        XCTAssertTrue(app.staticTexts["Title can't be empty."].waitForExistence(timeout: 5))
    }

    func testInspectorCloseButtonDismissesThePanel() {
        let title = openFirstBacklogCard()
        app.buttons["inspector.close"].firstMatch.click()

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
    }

    func testNewProjectStartDateToggleRevealsThePicker() {
        app.loadDemoWorkspace()
        app.typeKey("n", modifierFlags: [.command, .shift])

        let toggle = app.element("project.hasStart")
        let picker = app.element("project.start")
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertFalse(picker.exists)

        toggle.click()
        XCTAssertTrue(picker.waitForExistence(timeout: 5))

        toggle.click()
        XCTAssertTrue(picker.waitForNonExistence(timeout: 5))
    }
}
#endif
