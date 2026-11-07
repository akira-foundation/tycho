#if os(macOS)
import AppKit
import XCTest

@MainActor
final class TychoFiltersTests: XCTestCase {
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

    private var websiteRows: XCUIElementQuery {
        app.elements(withIdentifierPrefix: "task.WEB-")
    }

    private func addFilter(_ title: String) {
        app.filterButton.click()
        let add = element("filter.add")
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.click()
        app.menuItems[title].firstMatch.click()
    }

    private func closeFilter() {
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(element("filter.builder").waitForNonExistence(timeout: 5))
    }

    private func addStatusDoneFilter() {
        addFilter("Status")
        let done = element("filter.value.done")
        XCTAssertTrue(done.waitForExistence(timeout: 5), "adding a filter should show its values")
        done.click()
        XCTAssertTrue(eventually { (done.value as? Int) == 1 }, "clicking Done should select it")
        closeFilter()
    }

    private func viewMenuItem(_ title: String) -> XCUIElement {
        element("project.tab.view.menu").click()
        let item = app.menuItems[title].firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        return item
    }

    func testAddingAFilterShowsItsValues() {
        app.openWebsiteTab("List")
        addFilter("Status")

        XCTAssertTrue(element("filter.values.0").waitForExistence(timeout: 5))
        XCTAssertTrue(element("filter.value.done").exists)
        element("filter.clear").click()
        XCTAssertTrue(element("filter.values.0").waitForNonExistence(timeout: 5))
        closeFilter()
    }

    func testReopeningTheFilterKeepsItsFields() {
        app.openWebsiteTab("List")
        addFilter("Priority")
        closeFilter()

        app.filterButton.click()

        let field = element("filter.field.0")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "Priority")
        element("filter.clear").click()
        closeFilter()
    }

    func testStatusFilterNarrowsTheListAndClearAllRestoresIt() {
        app.openWebsiteTab("List")
        XCTAssertTrue(element("task.WEB-118").waitForExistence(timeout: 5))
        let before = websiteRows.count

        addStatusDoneFilter()

        XCTAssertTrue(eventually { self.websiteRows.count > 0 && self.websiteRows.count < before })
        XCTAssertFalse(element("task.WEB-118").exists)

        app.filterButton.click()
        element("filter.clear").click()
        closeFilter()

        XCTAssertTrue(eventually { self.websiteRows.count == before })
    }

    func testSavingRenamingAndDeletingAView() throws {
        let widest = NSScreen.screens.map(\.visibleFrame.width).max() ?? 0
        try XCTSkipUnless(widest >= 1500, "the project toolbar needs a zoomed window at least 1500 pt wide")
        app.zoomWindow()
        app.openWebsiteTab("List")
        addStatusDoneFilter()

        element("project.tab.saveView").click()
        let name = element("saveView.name")
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.click()
        name.typeText("Shipped")
        element("saveView.save").click()
        let saved = element("project.tab.view.Shipped")
        XCTAssertTrue(saved.waitForExistence(timeout: 5))

        viewMenuItem("Rename view").click()
        let rename = element("renameView.name")
        XCTAssertTrue(rename.waitForExistence(timeout: 5))
        rename.click()
        rename.typeKey("a", modifierFlags: .command)
        rename.typeText("Released")
        element("renameView.save").click()
        let renamed = element("project.tab.view.Released")
        XCTAssertTrue(renamed.waitForExistence(timeout: 5))
        XCTAssertFalse(saved.exists)

        viewMenuItem("Delete view").click()
        XCTAssertTrue(renamed.waitForNonExistence(timeout: 5))
        XCTAssertTrue(element("project.tab.saveView").exists)
    }

    func testHomeOverdueCardOpensTasksWithTheDueChip() {
        let board = app.radioButtons["Board"].firstMatch
        app.openSidebarItem("Tasks", revealing: board)
        board.click()
        XCTAssertTrue(element("column.todo").waitForExistence(timeout: 5))

        let overdue = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Overdue,'")).firstMatch
        app.openSidebarItem("Home", revealing: overdue)
        overdue.click()

        XCTAssertTrue(app.elements(withIdentifierPrefix: "group.").firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(element("column.todo").exists)
        app.filterButton.click()
        let field = element("filter.field.0")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "Due")
    }
}
#endif
