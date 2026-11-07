import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskPropertiesSectionTests {
    @Test func labelSummaryListsLabelsInCatalogueOrder() {
        #expect(TaskPropertiesSection.labelSummary([]) == "None")
        let labels = Set(TaskLabel.allCases.prefix(2))
        let expected = TaskLabel.allCases.prefix(2).map(\.title).formatted(.list(type: .and, width: .narrow))
        #expect(TaskPropertiesSection.labelSummary(labels) == expected)
    }
}
