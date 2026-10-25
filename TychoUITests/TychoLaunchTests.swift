import XCTest

final class TychoLaunchTests: XCTestCase {
    @MainActor
    func testFirstLaunchShowsOnboarding() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.demo"].waitForExistence(timeout: 10))
    }
}
