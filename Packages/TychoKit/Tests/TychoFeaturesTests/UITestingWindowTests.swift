import CoreGraphics
import Testing

@testable import TychoFeatures

@MainActor
struct UITestingWindowTests {
    @Test func frameIsCentredInTheVisibleArea() {
        let frame = UITestingWindow.frame(in: CGRect(x: 0, y: 25, width: 1728, height: 1084))

        #expect(frame.size == UITestingWindow.size)
        #expect(frame.midX == 864)
        #expect(frame.midY == 567)
    }

    @Test func frameShrinksToASmallScreen() {
        let visible = CGRect(x: 0, y: 0, width: 1024, height: 700)

        let frame = UITestingWindow.frame(in: visible)

        #expect(frame == visible)
    }
}
