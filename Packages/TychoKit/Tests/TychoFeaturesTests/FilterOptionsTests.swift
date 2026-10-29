import Testing

@testable import TychoCore
@testable import TychoFeatures

struct FilterOptionsTests {
    @Test func assigneeOptionsStartWithUnassignedAndMarkMe() {
        let me = Member(name: "Kid", email: "kid@example.com", isMe: true)
        let sarah = Member(name: "Sarah", email: "sarah@example.com")
        let options = FilterOptions.options(for: .assignee, members: [sarah, me], projects: [])

        #expect(options.first == FilterOption(id: TaskFilter.noAssignee, title: "Unassigned"))
        #expect(options.map(\.title) == ["Unassigned", "Kid (you)", "Sarah"])
        #expect(options.last?.id == sarah.id.uuidString)
    }

    @Test func projectOptionsSkipArchived() {
        let second = Project(key: "B", name: "Beta")
        second.sortOrder = 2
        let first = Project(key: "A", name: "Alpha")
        first.sortOrder = 1
        let archived = Project(key: "C", name: "Gamma")
        archived.isArchived = true
        let options = FilterOptions.options(for: .project, members: [], projects: [second, archived, first])

        #expect(options.map(\.title) == ["Alpha", "Beta"])
        #expect(options.first?.id == first.id.uuidString)
    }

    @Test func summaryShowsAnyNamesOrCount() {
        let options = FilterOptions.options(for: .status, members: [], projects: [])
        let none = TaskFilter(field: .status)
        let two = TaskFilter(field: .status, values: ["todo", "done"])
        let three = TaskFilter(field: .status, values: ["todo", "done", "review"])

        #expect(FilterOptions.summary(none, options: options) == "any")
        #expect(FilterOptions.summary(two, options: options) == "To Do, Done")
        #expect(FilterOptions.summary(three, options: options) == "3 selected")
    }

    @Test func summaryOfAMissingValueIsACount() {
        let options = FilterOptions.options(for: .project, members: [], projects: [])
        let filter = TaskFilter(field: .project, values: ["gone"])

        #expect(FilterOptions.summary(filter, options: options) == "1 selected")
    }

    @Test func dueAndRecencyOptionsFollowTheOriginal() {
        let due = FilterOptions.options(for: .due, members: [], projects: [])
        let created = FilterOptions.options(for: .created, members: [], projects: [])
        let updated = FilterOptions.options(for: .updated, members: [], projects: [])

        #expect(due.map(\.id) == ["overdue", "today", "week", "later", "nodate"])
        #expect(created.map(\.id) == ["1", "7", "30"])
        #expect(created.map(\.title) == ["Last 24 hours", "Last 7 days", "Last 30 days"])
        #expect(updated == created)
    }
}
