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
        openPortalList()
        let header = element("group.review")
        XCTAssertTrue(header.waitForExistence(timeout: 5))

        header.hover()
        let disclosure = app.outlineRows.containing(.any, identifier: "group.review").disclosureTriangles.firstMatch
        XCTAssertTrue(disclosure.waitForExistence(timeout: 5))
        disclosure.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)).withOffset(CGVector(dx: -6, dy: 0))
            .click()

        let sheet = app.sheets.firstMatch
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        let pickers = sheet.popUpButtons
        XCTAssertTrue(pickers.matching(NSPredicate(format: "value == %@", "Customer Portal")).firstMatch.exists)
        XCTAssertTrue(pickers.matching(NSPredicate(format: "value == %@", "Review")).firstMatch.exists)
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(sheet.waitForNonExistence(timeout: 5))
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
}
#endif
