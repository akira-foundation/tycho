#if os(macOS)
import XCTest

@MainActor
final class TychoPaletteTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launchShowingWindow()
        app.loadDemoWorkspace()
        XCTAssertTrue(element("toolbar.palette").waitForExistence(timeout: 5))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.element(identifier)
    }

    private func openPalette() -> XCUIElement {
        app.typeKey("k", modifierFlags: .command)
        let input = element("palette.input")
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertTrue(eventually { input.hasFocus }, "the palette input should take the focus")
        return input
    }

    private func placeholder(of input: XCUIElement) -> String {
        input.placeholderValue ?? ""
    }

    func testToolbarButtonIsCompactAndKeepsTheProjectTabsInADefaultWindow() {
        let button = element("toolbar.palette")
        XCTAssertEqual(button.label, "Search or jump to…")
        XCTAssertLessThan(button.frame.width, 120)
        XCTAssertFalse(button.staticTexts["⌘K"].exists)
        app.openSidebarItem("Website Redesign", revealing: element("project.tab"))
    }

    func testToolbarButtonShowsItsSearchLabelInAWideWindow() throws {
        let widest = NSScreen.screens.map(\.visibleFrame.width).max() ?? 0
        try XCTSkipUnless(widest >= 1500, "the label needs a zoomed window at least 1500 pt wide")
        app.zoomWindow()
        let button = element("toolbar.palette")
        XCTAssertTrue(eventually { button.frame.width >= 160 }, "the label should be visible, not only in the tooltip")
    }

    func testCommandKOpensThePaletteAndEnterOpensAResult() {
        let input = openPalette()
        input.typeText("web")
        let items = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'palette.item.'"))
        XCTAssertTrue(eventually { items.count >= 2 && items.element(boundBy: 0).isSelected })
        app.typeKey(.downArrow, modifierFlags: [])
        XCTAssertTrue(
            eventually { items.element(boundBy: 1).isSelected && !items.element(boundBy: 0).isSelected },
            "Down should move the highlight to the second result")
        app.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(input.waitForNonExistence(timeout: 5))
        XCTAssertTrue(
            eventually { self.element("inspector.title").exists || self.element("project.tab").exists },
            "Enter should open the highlighted task or project")
    }

    func testTabSwitchesToSearchAndBackspaceReturnsToCommands() {
        let input = openPalette()
        XCTAssertEqual(placeholder(of: input), "Type a command or search…")

        app.typeKey(.tab, modifierFlags: [])
        XCTAssertTrue(eventually { self.placeholder(of: input) == "Search tasks, projects, files…" })

        app.typeKey(.delete, modifierFlags: [])
        XCTAssertTrue(eventually { self.placeholder(of: input) == "Type a command or search…" })

        app.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(input.waitForNonExistence(timeout: 5))
    }

    func testSlashOpensSearchAndViewAllShowsTheSearchPage() {
        app.typeKey("/", modifierFlags: [])
        let input = element("palette.input")
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertTrue(eventually { self.placeholder(of: input) == "Search tasks, projects, files…" })

        input.typeText("launch")
        let viewAll = element("palette.item.view-all")
        XCTAssertTrue(viewAll.waitForExistence(timeout: 5))
        XCTAssertTrue(viewAll.label.contains("View all results for “launch”"))
        app.typeKey(.upArrow, modifierFlags: [])
        XCTAssertTrue(eventually { viewAll.isHittable }, "the last item should scroll into view")
        viewAll.click()

        let field = element("search.field")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "launch")
        for (scope, title) in [("all", "All"), ("tasks", "Tasks"), ("projects", "Projects"), ("files", "Files")] {
            let tab = element("search.tab.\(scope)")
            XCTAssertTrue(tab.waitForExistence(timeout: 5), "missing the \(scope) tab")
            XCTAssertTrue(tab.label.hasPrefix("\(title) "), "unexpected label \(tab.label)")
            XCTAssertNotEqual(tab.label, "\(title) 0", "no \(scope) results for launch")
        }
    }
}
#endif
