#if os(macOS)
import XCTest

@MainActor
final class TychoViewsTests: XCTestCase {
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

    private func openSidebar(_ title: String, revealing identifier: String) {
        app.openSidebarItem(title, revealing: element(identifier))
    }

    private func text(of element: XCUIElement) -> String {
        element.value as? String ?? ""
    }

    private func contextMenuItem(_ title: String) -> XCUIElement {
        app.menuItems.matching(NSPredicate(format: "title == %@ AND enabled == true", title)).firstMatch
    }

    func testProjectsSummaryOpensAProject() {
        openSidebar("Projects", revealing: "project.row.WEB")
        element("project.row.WEB").click()
        XCTAssertTrue(element("project.tab").waitForExistence(timeout: 5))
    }

    func testEveryProjectTabOpens() {
        let markers = [
            ("Board", "column.todo"), ("List", "group.todo"), ("Table", "table.grid"),
            ("Calendar", "calendar.title"), ("Timeline", "timeline.header.week"), ("Files", "files.content"),
        ]
        openSidebar("Website Redesign", revealing: "project.tab")
        let picker = element("project.tab")
        for (tab, marker) in markers {
            picker.descendants(matching: .any)[tab].firstMatch.click()
            XCTAssertTrue(element(marker).waitForExistence(timeout: 5), "\(tab) did not open")
        }
    }

    func testProjectTabsShowIconsNamedByTitle() {
        openSidebar("Website Redesign", revealing: "project.tab")
        app.zoomWindow()
        let picker = element("project.tab")
        for tab in ["Board", "List", "Table", "Calendar", "Timeline", "Files"] {
            let segment = picker.radioButtons[tab].firstMatch
            XCTAssertTrue(segment.exists, "\(tab) segment should be named by its title")
            XCTAssertLessThanOrEqual(segment.frame.width, 48, "\(tab) segment should show only its icon")
        }
    }

    func testTableHeaderSortsByPriority() {
        app.openWebsiteTab("Table")
        let handoff = element("table.title.WEB-124")
        let tokens = element("table.title.WEB-118")
        XCTAssertTrue(handoff.waitForExistence(timeout: 5))
        XCTAssertTrue(tokens.waitForExistence(timeout: 5))
        let handoffFirst = handoff.frame.minY < tokens.frame.minY

        element("table.grid").buttons["Priority"].firstMatch.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
        ).click()

        XCTAssertTrue(eventually { (handoff.frame.minY < tokens.frame.minY) != handoffFirst })
    }

    func testTableStatusCellChangesTheStatus() {
        app.openWebsiteTab("Table")
        let status = element("table.status.WEB-118")
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        status.click()
        app.menuItems["In Progress"].firstMatch.click()

        XCTAssertTrue(
            eventually {
                (status.value as? String) == "In Progress" || status.label.contains("In Progress")
            })
    }

    func testTableAssigneeCellShowsTheNameAndReassigns() {
        app.openWebsiteTab("Table")
        let assignee = element("table.assignee.WEB-124")
        XCTAssertTrue(assignee.waitForExistence(timeout: 5))
        XCTAssertEqual(assignee.title, "Sarah Chen")
        let avatar = element("table.avatar.WEB-124")
        XCTAssertTrue(avatar.exists)
        XCTAssertLessThanOrEqual(avatar.frame.maxX, assignee.frame.minX)

        assignee.click()
        app.menuItems["Emma Wilson"].firstMatch.click()

        XCTAssertTrue(eventually { assignee.title == "Emma Wilson" })
    }

    func testTableTitleRenamesInlineAndEscapeCancels() {
        app.openWebsiteTab("Table")
        let title = element("table.title.WEB-118")
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        title.doubleClick()
        app.typeKey("a", modifierFlags: .command)
        app.typeText("Tokens renamed\r")
        XCTAssertTrue(eventually { title.label.contains("Tokens renamed") })

        title.doubleClick()
        app.typeKey("a", modifierFlags: .command)
        app.typeText("Discarded")
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(eventually { title.label.contains("Tokens renamed") && title.label.contains("WEB-118") })
    }

    func testTableEstimateEditsInline() {
        app.openWebsiteTab("Table")
        for column in ["Status", "Priority", "Assignee", "Due date", "Labels"] {
            app.viewOptionsMenu.click()
            app.menuItems["Columns"].firstMatch.hover()
            app.menuItems[column].firstMatch.click()
        }
        let estimate = element("table.estimate.WEB-118")
        XCTAssertTrue(estimate.waitForExistence(timeout: 5))

        estimate.click()
        app.typeKey("a", modifierFlags: .command)
        app.typeText("5d\r")

        XCTAssertTrue(eventually { text(of: element("table.estimate.WEB-118")) == "5d" })
    }

    func testCalendarMovesBetweenMonthsAndBackToToday() {
        openSidebar("Calendar", revealing: "calendar.title")
        let title = element("calendar.title")
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let current = text(of: title)

        element("calendar.next").click()
        XCTAssertTrue(eventually { text(of: title) != current })
        element("calendar.today").click()
        XCTAssertTrue(eventually { text(of: title) == current })
    }

    func testCalendarOpensTheDayList() throws {
        openSidebar("Calendar", revealing: "calendar.title")
        let overflow = NSPredicate(format: "label ENDSWITH %@", "more")
        let overflows = app.buttons.matching(overflow)
        XCTAssertTrue(overflows.firstMatch.waitForExistence(timeout: 5))
        let grid = app.scrollViews.containing(overflow).firstMatch
        var reachable = overflows.allElementsBoundByIndex.first(where: \.isHittable)
        for delta in [-300.0, 600.0] where reachable == nil {
            grid.scroll(byDeltaX: 0, deltaY: delta)
            reachable = overflows.allElementsBoundByIndex.first(where: \.isHittable)
        }
        let more = try XCTUnwrap(reachable, "no reachable +N more button")
        more.click()
        let list = element("calendar.daylist")
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        let popover = app.popovers.firstMatch
        XCTAssertTrue(element("calendar.daylist.title").exists)
        let rows = list.buttons.allElementsBoundByIndex
        let lastRow = try XCTUnwrap(rows.last)
        try XCTSkipIf(rows.count > 8, "the seeded day overflows the capped list")
        for row in rows {
            XCTAssertTrue(row.isHittable, "every item of the day should show without scrolling")
        }
        let gap = popover.frame.maxY - lastRow.frame.maxY
        XCTAssertTrue((0...32).contains(gap), "the day list popover should fit its items, gap \(gap)")
    }

    func testTimelineSwitchesToMonths() {
        openSidebar("Timeline", revealing: "timeline.zoom")
        XCTAssertTrue(element("timeline.header.week").waitForExistence(timeout: 5))
        element("timeline.zoom").descendants(matching: .any)["Months"].firstMatch.click()
        XCTAssertTrue(element("timeline.header.month").waitForExistence(timeout: 5))
    }

    func testListGroupHeaderCollapsesAndExpands() {
        app.openWebsiteTab("List")
        let header = element("group.todo")
        let row = element("task.WEB-118")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let disclosure = app.outlineRows.containing(.any, identifier: "group.todo").disclosureTriangles.firstMatch

        header.hover()
        disclosure.click()
        XCTAssertTrue(row.waitForNonExistence(timeout: 5))

        header.hover()
        disclosure.click()
        XCTAssertTrue(row.waitForExistence(timeout: 5))
    }

    func testFilesDuplicateAndDelete() {
        app.openWebsiteTab("Files")
        let original = element("file.sitemap-v2.pdf")
        XCTAssertTrue(original.waitForExistence(timeout: 5))
        original.rightClick()
        contextMenuItem("Duplicate").click()

        let copy = element("file.sitemap-v2 copy.pdf")
        XCTAssertTrue(copy.waitForExistence(timeout: 5))
        copy.rightClick()
        contextMenuItem("Delete").click()
        let confirm = app.sheets.buttons["Delete File"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.click()

        XCTAssertTrue(copy.waitForNonExistence(timeout: 5))
        XCTAssertTrue(original.exists)
    }
}
#endif
