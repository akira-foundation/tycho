#if os(macOS)
import XCTest

@MainActor
final class TychoViewsTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        let demo = app.buttons["onboarding.demo"]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        demo.click()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    private func openSidebar(_ title: String) {
        app.outlines.staticTexts[title].firstMatch.click()
    }

    private func openWebsiteTab(_ tab: String) {
        openSidebar("Website Redesign")
        let picker = element("project.tab")
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.descendants(matching: .any)[tab].firstMatch.click()
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
        openSidebar("Website Redesign")
        let picker = element("project.tab")
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
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
        openSidebar("Calendar")
        let title = element("calendar.title")
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let current = text(of: title)

        element("calendar.next").click()
        XCTAssertTrue(eventually { text(of: title) != current })
        element("calendar.today").click()
        XCTAssertTrue(eventually { text(of: title) == current })
    }

    func testCalendarOpensTheDayList() {
        openSidebar("Calendar")
        let more = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", "more")).firstMatch
        XCTAssertTrue(more.waitForExistence(timeout: 5))
        more.click()
        XCTAssertTrue(element("calendar.daylist").waitForExistence(timeout: 5))
    }

    func testTimelineSwitchesToMonths() {
        openSidebar("Timeline")
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
