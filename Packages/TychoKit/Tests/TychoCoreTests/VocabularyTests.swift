import Testing

@testable import TychoCore

struct VocabularyTests {
    @Test func prioritiesKeepTheOriginalWeights() {
        #expect(TaskPriority.allCases.map(\.weight) == [4, 3, 2, 1, 0])
        #expect(TaskPriority.noPriority.rawValue == "none")
        #expect(TaskPriority.noPriority.title == "No priority")
        #expect(TaskPriority.urgent.title == "Urgent")
    }

    @Test func labelsMatchTheOriginalSet() {
        #expect(
            TaskLabel.allCases.map(\.rawValue) == [
                "design", "frontend", "backend", "research", "content", "bug", "qa", "growth",
            ])
        #expect(TaskLabel.qa.title == "QA")
        #expect(TaskLabel.frontend.title == "Frontend")
    }

    @Test func projectStatusesUseTheOriginalTitles() {
        #expect(
            ProjectStatus.allCases.map(\.title) == [
                "Planning", "In Progress", "At Risk", "On Hold", "Completed",
            ])
    }

    @Test func projectColorsCarryTheOriginalHex() {
        #expect(ProjectColor.indigo.hex == 0x5A67D8)
        #expect(ProjectColor.blue.hex == 0x3B82C4)
        #expect(ProjectColor.violet.hex == 0x8662C9)
        #expect(ProjectColor.teal.hex == 0x23918A)
        #expect(ProjectColor.rose.hex == 0xC54B78)
        #expect(ProjectColor.amber.hex == 0xC48A1E)
        #expect(ProjectColor.green.hex == 0x3D8E5F)
        #expect(ProjectColor.slate.hex == 0x6B7280)
    }

    @Test func rolesHaveTitles() {
        #expect(MemberRole.allCases.map(\.title) == ["Owner", "Admin", "Member", "Guest"])
    }
}
