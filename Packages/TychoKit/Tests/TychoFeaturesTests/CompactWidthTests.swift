import SwiftUI
import Testing

@testable import TychoFeatures

struct CompactWidthTests {
    @Test func regularWidthByDefault() {
        #expect(!EnvironmentValues().isCompactWidth)
    }

    #if os(iOS)
    @Test func compactSizeClassIsCompactWidth() {
        var environment = EnvironmentValues()
        environment.horizontalSizeClass = .compact
        #expect(environment.isCompactWidth)
    }
    #endif
}
