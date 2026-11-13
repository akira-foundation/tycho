#if os(macOS)
import XCTest

@MainActor
final class TychoListTests: XCTestCase {
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

    private func openPortalList() {
        app.openSidebarItem("Customer Portal", revealing: element("project.tab"))
        app.openProjectTab("List")
        XCTAssertTrue(element("task.CP-103").waitForExistence(timeout: 5))
    }

    func testGroupsHaveNoAddTaskRow() {
        app.openWebsiteTab("List")
        XCTAssertTrue(element("task.WEB-118").waitForExistence(timeout: 5))
        let composers = app.textFields.matching(NSPredicate(format: "placeholderValue == %@", "Add Task"))
        XCTAssertEqual(composers.count, 0)
    }

    func testGroupAddButtonOpensTheNewTaskSheetWithThatStatus() {
        app.openWebsiteTab("List")
        let header = element("group.review")
        let add = element("group.review.add")
        XCTAssertTrue(header.waitForExistence(timeout: 5))
        XCTAssertTrue(add.exists, "the add button should stay in the accessibility tree without hovering")

        header.hover()
        add.click()

        let status = app.popUpButtons["Status"].firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertEqual(status.value as? String, "Review")
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(status.waitForNonExistence(timeout: 5))
    }

    func testEmptyGroupShowsOnlyItsHeader() {
        openPortalList()
        let row = element("task.CP-103")
        let review = element("group.review")
        let done = element("group.done")
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        let rows = app.elements(withIdentifierPrefix: "task.").allElementsBoundByIndex
        XCTAssertFalse(rows.contains { $0.frame.minY > review.frame.maxY && $0.frame.maxY < done.frame.minY })
        XCTAssertLessThan(done.frame.minY - review.frame.maxY, row.frame.height)
    }

    func testDroppingOntoAnEmptyGroupMovesTheTask() {
        openPortalList()
        let row = element("task.CP-103")
        let review = element("group.review")
        let done = element("group.done")
        XCTAssertTrue(review.waitForExistence(timeout: 5))
        XCTAssertLessThan(row.frame.minY, review.frame.minY)

        row.press(forDuration: 0.6, thenDragTo: review)

        XCTAssertTrue(eventually { row.frame.minY > review.frame.maxY && row.frame.maxY < done.frame.minY })
    }
}
#endif
