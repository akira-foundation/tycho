#if os(macOS)
import XCTest

extension XCUIApplication {
    func element(_ identifier: String) -> XCUIElement {
        descendants(matching: .any)[identifier].firstMatch
    }

    func elements(withIdentifierPrefix prefix: String) -> XCUIElementQuery {
        descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
    }

    func loadDemoWorkspace() {
        let demo = buttons["onboarding.demo"]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        demo.click()
    }

    func openSidebarItem(_ title: String, revealing marker: XCUIElement) {
        for _ in 0..<3 where !marker.exists {
            let item = outlines.staticTexts[title].firstMatch
            if item.waitForExistence(timeout: 5) { item.click() }
            _ = marker.waitForExistence(timeout: 3)
        }
        XCTAssertTrue(marker.exists, "\(title) did not open")
    }

    func openWebsiteTab(_ tab: String) {
        openSidebarItem("Website Redesign", revealing: element("project.tab"))
        openProjectTab(tab)
    }

    func openProjectTab(_ tab: String) {
        let picker = element("project.tab")
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.descendants(matching: .any)[tab].firstMatch.click()
    }

    var filterButton: XCUIElement { buttons["Filter"].firstMatch }

    var viewOptionsMenu: XCUIElement { menuButtons["View Options"].firstMatch }

    func zoomWindow() {
        menuBars.menuBarItems["Window"].click()
        menuItems["Zoom"].firstMatch.click()
    }
}

extension XCUIElement {
    var hasFocus: Bool {
        (value(forKey: "hasKeyboardFocus") as? Bool) == true
    }
}
#endif
