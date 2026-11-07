import Testing

@testable import TychoFeatures

struct FilterToolbarButtonTests {
    @Test func theSymbolFillsOnlyWhileFiltersApply() {
        #expect(FilterToolbarButton.symbol(filterCount: 0) == "line.3.horizontal.decrease.circle")
        #expect(FilterToolbarButton.symbol(filterCount: 2) == "line.3.horizontal.decrease.circle.fill")
    }
}
