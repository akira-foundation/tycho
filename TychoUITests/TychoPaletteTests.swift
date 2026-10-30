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

    func testCommandKOpensThePaletteAndEnterOpensAResult() {
        let input = openPalette()
        input.typeText("web")
        app.typeKey(.downArrow, modifierFlags: [])
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

        input.typeText("web")
        let viewAll = element("palette.item.view-all")
        XCTAssertTrue(viewAll.waitForExistence(timeout: 5))
        XCTAssertTrue(viewAll.label.contains("View all results for “web”"))
        app.typeKey(.upArrow, modifierFlags: [])
        XCTAssertTrue(eventually { viewAll.isHittable }, "the last item should scroll into view")
        viewAll.click()

        let field = element("search.field")
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "web")
        let all = element("search.tab.all")
        XCTAssertTrue(all.waitForExistence(timeout: 5))
        XCTAssertTrue(all.label.hasPrefix("All "))
        XCTAssertNotEqual(all.label, "All 0")
        for scope in ["tasks", "projects", "files"] {
            XCTAssertTrue(element("search.tab.\(scope)").exists, "missing the \(scope) tab")
        }
    }
}
#endif
