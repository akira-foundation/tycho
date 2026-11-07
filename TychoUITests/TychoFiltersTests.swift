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

    private func projectMenuItem(_ title: String) -> XCUIElement {
        element("project.menu").click()
        let item = app.menuItems[title].firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        return item
    }

    private func projectMenuLists(_ title: String) -> Bool {
        element("project.menu").click()
        defer { app.typeKey(.escape, modifierFlags: []) }
        return app.menuItems[title].firstMatch.waitForExistence(timeout: 5)
    }

    private func projectMenuOmits(_ title: String) -> Bool {
        element("project.menu").click()
        defer { app.typeKey(.escape, modifierFlags: []) }
        let opened = app.menuItems["Save View…"].firstMatch.waitForExistence(timeout: 5)
        return opened && !app.menuItems[title].firstMatch.exists
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

    func testTwoFiltersShowWholeInsideTheScreen() {
        app.openWebsiteTab("List")
        addFilter("Status")
        element("filter.add").click()
        app.menuItems["Priority"].firstMatch.click()

        let clear = element("filter.clear")
        XCTAssertTrue(element("filter.value.low").waitForExistence(timeout: 5))
        XCTAssertTrue(element("filter.value.low").isHittable, "the second filter should show without scrolling")
        XCTAssertTrue(clear.isHittable, "the whole form should show without scrolling")
        let screens = NSScreen.screens.map(\.frame)
        let builder = element("filter.builder").frame
        XCTAssertTrue(
            screens.contains { $0.minX <= builder.minX && builder.maxX <= $0.maxX },
            "the filter popover should stay inside one screen")
        clear.click()
        closeFilter()
    }

    func testManyFiltersScrollInsideACappedPopover() {
        app.openWebsiteTab("List")
        addFilter("Status")
        for title in ["Priority", "Labels", "Assignee", "Project", "Due date"] {
            element("filter.add").click()
            let item = app.menuItems[title].firstMatch
            XCTAssertTrue(item.waitForExistence(timeout: 5))
            item.click()
        }

        XCTAssertTrue(element("filter.values.5").waitForExistence(timeout: 5))
        XCTAssertLessThanOrEqual(element("filter.builder").frame.height, 660, "the popover should cap its height")
        element("filter.clear").click()
        XCTAssertTrue(element("filter.values.0").waitForNonExistence(timeout: 5))
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

    func testSavingRenamingAndDeletingAView() {
        app.openWebsiteTab("List")
        addStatusDoneFilter()

        projectMenuItem("Save View…").click()
        let name = element("saveView.name")
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.click()
        name.typeText("Shipped")
        element("saveView.save").click()
        XCTAssertTrue(projectMenuLists("Shipped"))

        projectMenuItem("Rename View…").click()
        let rename = element("renameView.name")
        XCTAssertTrue(rename.waitForExistence(timeout: 5))
        rename.click()
        rename.typeKey("a", modifierFlags: .command)
        rename.typeText("Released")
        element("renameView.save").click()
        XCTAssertTrue(projectMenuLists("Released"))
        XCTAssertTrue(projectMenuOmits("Shipped"))

        projectMenuItem("Delete View").click()
        XCTAssertTrue(projectMenuOmits("Released"))
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
        XCTAssertEqual(field.value as? String, "Due date")
    }
}
#endif
