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

    private func createProjectWithKeys(_ name: String) {
        app.buttons["New Project"].firstMatch.click()
        let field = element("project.name")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertTrue(eventually { field.hasFocus }, "the name should take focus when the sheet opens")
        app.typeText(name)
        app.typeKey(.return, modifierFlags: [])
        XCTAssertTrue(field.waitForNonExistence(timeout: 5))
        XCTAssertTrue(element("project.tab").waitForExistence(timeout: 5))
    }

    private var cards: XCUIElementQuery {
        app.elements(withIdentifierPrefix: "card.").matching(NSPredicate(format: "NOT identifier ENDSWITH '.toggle'"))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
    }

    private func openNewTask() -> XCUIElement {
        if !element("project.tab").exists { createProjectWithKeys("Alpha") }
        app.typeKey("n", modifierFlags: .command)
        let title = element("task.title")
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertTrue(eventually { title.hasFocus }, "the title should take focus when the sheet opens")
        return title
    }

    func testReturnInTheTitleCreatesTheTask() {
        let title = openNewTask()
        app.typeText("Typed with keys")
        app.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(cards.count, 1)
        XCTAssertTrue(cards.firstMatch.buttons["Typed with keys"].exists)
    }

    func testReturnWithAnEmptyTitleKeepsTheSheetOpen() {
        let title = openNewTask()
        app.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(app.staticTexts["Title can't be empty."].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(title.exists)
    }

    func testOptionReturnBreaksTheDescriptionAndReturnCreatesTheTask() {
        let title = openNewTask()
        app.typeText("Task with notes")
        app.typeKey(.tab, modifierFlags: [])
        let notes = element("task.notes")
        XCTAssertTrue(eventually { notes.hasFocus }, "Tab should move from the title to the notes")
        app.typeText("First line")
        app.typeKey(.return, modifierFlags: .option)
        app.typeText("Second line")
        XCTAssertEqual(notes.value as? String, "First line\nSecond line")
        XCTAssertTrue(title.exists, "Option-Return should not create the task")

        app.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        let card = cards.firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        let cardTitle = card.buttons["Task with notes"]
        XCTAssertTrue(cardTitle.exists)
        cardTitle.click()
        XCTAssertTrue(app.textFields["inspector.title"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["First line\nSecond line"].firstMatch.waitForExistence(timeout: 5))
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

    func testEscapeCancelsWithoutCreating() {
        let title = openNewTask()
        app.typeText("Never created")
        app.typeKey(.escape, modifierFlags: [])

        XCTAssertTrue(title.waitForNonExistence(timeout: 5))
        XCTAssertEqual(cards.count, 0)
    }
}
#endif
