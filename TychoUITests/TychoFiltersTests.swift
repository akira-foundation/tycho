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

    private func addStatusDoneFilter() {
        element("view.filter").click()
        let addStatus = element("filter.add.status")
        XCTAssertTrue(addStatus.waitForExistence(timeout: 5))
        addStatus.click()
        let done = element("filter.value.done")
        XCTAssertTrue(done.waitForExistence(timeout: 5), "adding a filter should open its value list")
        done.click()
        XCTAssertTrue(eventually { done.isSelected }, "clicking Done should select it")
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(element("filter.builder").waitForNonExistence(timeout: 5))
    }

    private func viewMenuItem(_ title: String) -> XCUIElement {
        element("project.tab.view.menu").click()
        let item = app.menuItems[title].firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        return item
    }

    func testAddingAFilterOpensItsValueList() {
        app.openWebsiteTab("List")
        for attempt in 1...3 {
            element("view.filter").click()
            let addStatus = element("filter.add.status")
            XCTAssertTrue(addStatus.waitForExistence(timeout: 5))
            addStatus.click()
            let list = element("filter.values.0")
            XCTAssertTrue(
                list.waitForExistence(timeout: 5), "attempt \(attempt): adding Status should open its value list")
            XCTAssertGreaterThan(list.frame.height, 40, "attempt \(attempt): the value list should show its options")
            element("filter.clear").click()
            app.typeKey(.escape, modifierFlags: [])
            XCTAssertTrue(element("filter.builder").waitForNonExistence(timeout: 5))
        }
    }

    func testStatusFilterNarrowsTheListAndClearAllRestoresIt() {
        app.openWebsiteTab("List")
        XCTAssertTrue(element("task.WEB-118").waitForExistence(timeout: 5))
        let before = websiteRows.count

        addStatusDoneFilter()

        let chip = element("filter.chip.0")
        XCTAssertTrue(chip.waitForExistence(timeout: 5))
        XCTAssertTrue(chip.label.contains("Status"))
        XCTAssertTrue(eventually { self.websiteRows.count > 0 && self.websiteRows.count < before })
        XCTAssertFalse(element("task.WEB-118").exists)

        element("filter.chips.clear").click()

        XCTAssertTrue(chip.waitForNonExistence(timeout: 5))
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
        app.openSidebarItem("Tasks", revealing: element("tasks.mode"))
        element("tasks.mode").descendants(matching: .any)["Board"].firstMatch.click()
        XCTAssertTrue(element("column.todo").waitForExistence(timeout: 5))

        let overdue = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Overdue,'")).firstMatch
        app.openSidebarItem("Home", revealing: overdue)
        overdue.click()

        let chip = element("filter.chip.0")
        XCTAssertTrue(chip.waitForExistence(timeout: 5))
        XCTAssertTrue(chip.label.contains("Due"))
        XCTAssertTrue(app.elements(withIdentifierPrefix: "group.").firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(element("column.todo").exists)
    }
}
#endif
