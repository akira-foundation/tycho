import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskPropertiesSectionTests {
    @Test func labelSummaryListsLabelsInCatalogueOrder() {
        #expect(TaskPropertiesSection.labelSummary([]) == "None")
        #expect(TaskPropertiesSection.labelSummary([.qa, .bug, .design]) == "Design, Bug, QA")
    }
}
