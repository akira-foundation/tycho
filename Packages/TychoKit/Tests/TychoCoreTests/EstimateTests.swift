import Testing

@testable import TychoCore

struct EstimateTests {
    @Test func blankEstimatesClearTheValue() {
        #expect(Estimate.normalized(" 3d ") == "3d")
        #expect(Estimate.normalized("   ") == nil)
        #expect(Estimate.normalized("") == nil)
        #expect(Estimate.normalized(nil) == nil)
    }
}
