import Testing

@testable import TychoFeatures

struct EstimateOptionsTests {
    @Test func quickOptionsFollowTheOriginal() {
        #expect(EstimateOptions.quick == ["30m", "1h", "2h", "4h", "1d", "2d", "3d", "5d", "8d"])
    }

    @Test func blankEstimatesClearTheValue() {
        #expect(EstimateOptions.normalized(" 3d ") == "3d")
        #expect(EstimateOptions.normalized("   ") == nil)
    }
}
