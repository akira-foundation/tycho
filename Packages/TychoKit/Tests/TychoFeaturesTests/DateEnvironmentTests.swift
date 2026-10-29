import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct DateEnvironmentTests {
    @Test func defaultsMatchTheOriginalPreferences() {
        let values = EnvironmentValues()
        #expect(values.weekStart == .monday)
        #expect(values.dateText.format == .monthDay)
    }

    @Test func preferenceKeysAreDistinct() {
        let keys = [
            AppearanceKey.theme, AppearanceKey.density, AppearanceKey.motion,
            AppearanceKey.weekStart, AppearanceKey.dateFormat,
        ]
        #expect(Set(keys).count == keys.count)
    }
}
