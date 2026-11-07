#if os(iOS)
import XCTest

@MainActor
final class TychoCompactTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .phone, "compact width needs an iPhone")
        app.launch()
        let demo = app.buttons["onboarding.demo"]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        demo.tap()
    }

    private func openProject(_ name: String) {
        let title = app.navigationBars[name]
        for detour in ["Mobile App", name] where !title.exists {
            let back = app.navigationBars.buttons["BackButton"]
            if back.waitForExistence(timeout: 2) { back.tap() }
            let row = app.collectionViews.staticTexts[detour].firstMatch
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
            XCTAssertTrue(app.navigationBars[detour].waitForExistence(timeout: 3), "\(detour) did not open")
        }
        XCTAssertTrue(title.waitForExistence(timeout: 3), "\(name) did not open")
    }

    func testProjectViewPickerNamesTheCurrentViewAndSwitches() {
        openProject("Website Redesign")
        let picker = app.buttons["project.tab"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        XCTAssertEqual(picker.label, "Board")

        picker.tap()
        app.buttons["Table"].firstMatch.tap()

        XCTAssertTrue(eventually { picker.label == "Table" })
    }

    func testProjectLargeTitleSitsAboveTheSavedViewStrip() {
        openProject("Website Redesign")
        let bar = app.navigationBars["Website Redesign"]
        let title = bar.staticTexts["Website Redesign"]
        let subtitle = bar.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'In Progress'")).firstMatch
        let strip = app.otherElements["savedViews.strip"]
        XCTAssertTrue(strip.waitForExistence(timeout: 5))

        XCTAssertTrue(title.isHittable, "the large title should be visible")
        XCTAssertTrue(subtitle.exists, "the status and progress subtitle should be visible")
        XCTAssertLessThanOrEqual(title.frame.maxY, strip.frame.minY)
        XCTAssertGreaterThan(inkShare(title.screenshot().image), 0.1, "the large title should not sit under a blur")
    }

    private func inkShare(_ image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0 }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let context = CGContext(
                    data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                    bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return 0 }
        let brightness = { (index: Int) in Int(pixels[index]) + Int(pixels[index + 1]) + Int(pixels[index + 2]) }
        let background = brightness(0)
        let ink = stride(from: 0, to: pixels.count, by: 4).filter { abs(brightness($0) - background) > 3 * 128 }
        return Double(ink.count) / Double(width * height)
    }

    func testNewTaskSheetCancelsFromTheNavigationBar() {
        openProject("Website Redesign")
        app.buttons["New Task"].firstMatch.tap()
        let sheetBar = app.navigationBars["New task"]
        XCTAssertTrue(sheetBar.waitForExistence(timeout: 5))
        XCTAssertTrue(sheetBar.buttons["task.create"].exists)

        sheetBar.buttons["Cancel"].tap()

        XCTAssertTrue(eventually { !sheetBar.exists })
    }

    func testMyTasksSearchFilterAndOptionsSitInTheBottomBar() {
        openProject("My Tasks")
        let controls = [app.buttons["Filter"], app.searchFields.firstMatch, app.buttons["View Options"]]
        XCTAssertTrue(controls[0].waitForExistence(timeout: 5))
        let bottom = app.windows.firstMatch.frame.height * 0.8
        for control in controls {
            XCTAssertTrue(control.exists)
            XCTAssertGreaterThan(control.frame.midY, bottom)
        }
    }

    func testSidebarSettingsLivesInTheNavigationBar() {
        let back = app.navigationBars.buttons["BackButton"]
        if back.waitForExistence(timeout: 3) { back.tap() }
        let settings = app.navigationBars["Tycho"].buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
    }
}
#endif
