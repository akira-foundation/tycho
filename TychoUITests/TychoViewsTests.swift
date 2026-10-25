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

    private func openWebsiteTab(_ tab: String) {
        openSidebar("Website Redesign", revealing: "project.tab")
        element("project.tab").descendants(matching: .any)[tab].firstMatch.click()
    }

    private func text(of element: XCUIElement) -> String {
        element.value as? String ?? ""
    }

    private func contextMenuItem(_ title: String) -> XCUIElement {
        app.menuItems.matching(NSPredicate(format: "title == %@ AND enabled == true", title)).firstMatch
    }

    private func eventually(timeout: TimeInterval = 5, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return condition()
    }

    func testEveryProjectTabOpens() {
        let markers = [
            ("Board", "column.todo"), ("List", "group.todo"), ("Table", "table.columns"),
            ("Calendar", "calendar.title"), ("Timeline", "timeline.zoom"), ("Files", "files.search"),
        ]
        openSidebar("Website Redesign", revealing: "project.tab")
        let picker = element("project.tab")
        for (tab, marker) in markers {
            picker.descendants(matching: .any)[tab].firstMatch.click()
            XCTAssertTrue(element(marker).waitForExistence(timeout: 5), "\(tab) did not open")
        }
    }

    func testTableHeaderSortsByPriority() {
        openWebsiteTab("Table")
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
        openWebsiteTab("Table")
        let status = element("table.status.WEB-118")
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        status.click()
        app.menuItems["In Progress"].firstMatch.click()

        XCTAssertTrue(
            eventually {
                (status.value as? String) == "In Progress" || status.label.contains("In Progress")
            })
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
        XCTAssertTrue(element("calendar.daylist").waitForExistence(timeout: 5))
    }

    func testTimelineSwitchesToMonths() {
        openSidebar("Timeline", revealing: "timeline.zoom")
        XCTAssertTrue(element("timeline.header.week").waitForExistence(timeout: 5))
        element("timeline.zoom").descendants(matching: .any)["Months"].firstMatch.click()
        XCTAssertTrue(element("timeline.header.month").waitForExistence(timeout: 5))
    }

    func testFilesDuplicateAndDelete() {
        openWebsiteTab("Files")
        let original = element("file.sitemap-v2.pdf")
        XCTAssertTrue(original.waitForExistence(timeout: 5))
        original.rightClick()
        contextMenuItem("Duplicate").click()

        let copy = element("file.sitemap-v2 copy.pdf")
        XCTAssertTrue(copy.waitForExistence(timeout: 5))
        copy.rightClick()
        contextMenuItem("Delete").click()
        let confirm = app.sheets.buttons["Delete file"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.click()

        XCTAssertTrue(copy.waitForNonExistence(timeout: 5))
        XCTAssertTrue(original.exists)
    }
}
#endif
