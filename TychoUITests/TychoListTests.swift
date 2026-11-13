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

    private func openMarketingList() {
        app.openSidebarItem("Marketing Campaign", revealing: element("project.tab"))
        app.openProjectTab("List")
        XCTAssertTrue(element("group.review").waitForExistence(timeout: 5))
    }

    func testGroupsHaveNoAddTaskRow() {
        app.openWebsiteTab("List")
        XCTAssertTrue(element("group.todo").waitForExistence(timeout: 5))
        XCTAssertFalse(app.textFields["Add Task"].exists)
    }

    func testGroupAddButtonOpensTheNewTaskSheetWithThatStatus() {
        app.openWebsiteTab("List")
        let header = element("group.review")
        let add = element("group.review.add")
        XCTAssertTrue(header.waitForExistence(timeout: 5))
        XCTAssertTrue(add.exists, "the add button should stay reachable without hovering")

        header.hover()
        add.click()

        let status = app.popUpButtons["Status"].firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertEqual(status.value as? String, "Review")
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(status.waitForNonExistence(timeout: 5))
    }

    func testEmptyGroupShowsOnlyItsHeader() {
        openMarketingList()
        let review = element("group.review")
        let done = element("group.done")
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        XCTAssertLessThan(done.frame.minY - review.frame.maxY, review.frame.height * 2)
    }

    func testDroppingOntoAnEmptyGroupMovesTheTask() {
        openMarketingList()
        let row = element("task.MKT-106")
        let review = element("group.review")
        let done = element("group.done")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertLessThan(row.frame.minY, review.frame.minY)

        row.press(forDuration: 0.6, thenDragTo: review)

        XCTAssertTrue(eventually { row.frame.minY > review.frame.maxY && row.frame.maxY < done.frame.minY })
    }
}
#endif
