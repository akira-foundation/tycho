#if os(macOS)
import XCTest

extension XCUIApplication {
    func element(_ identifier: String) -> XCUIElement {
        descendants(matching: .any)[identifier].firstMatch
    }

    func loadDemoWorkspace() {
        let demo = buttons["onboarding.demo"]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        typeKey(.escape, modifierFlags: [])
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
}
#endif
