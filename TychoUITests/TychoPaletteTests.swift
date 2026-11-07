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
        XCTAssertTrue(app.outlines.firstMatch.waitForExistence(timeout: 5))
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

    func testTheToolbarHasNoPaletteButtonBesideTheSearchField() {
        app.openSidebarItem("Tasks", revealing: app.searchFields.firstMatch)
        XCTAssertEqual(app.toolbars.searchFields.count, 1)
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

        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "launch")
        for title in ["All", "Tasks", "Projects", "Files"] {
            let scope = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "\(title) ")).firstMatch
            XCTAssertTrue(scope.waitForExistence(timeout: 5), "missing the \(title) scope")
            XCTAssertNotEqual(scope.label, "\(title) 0", "no \(title) results for launch")
        }
    }
}
#endif
