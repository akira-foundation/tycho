import Foundation
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskViewStateTests {
    @Test func statesAreStoredPerKeyAndFallBackToTheDefaults() {
        var project = TaskViewState(inProject: true)
        project.sort = [TaskComparator(field: .priority)]
        let data = TaskViewStates.storing(project, for: "p:1", in: Data())

        #expect(TaskViewStates.state(for: "p:1", inProject: true, in: data) == project)
        #expect(
            TaskViewStates.state(for: TaskViewStates.tasksKey, inProject: false, in: data)
                == TaskViewState(inProject: false))
        #expect(
            TaskViewStates.state(for: "p:1", inProject: true, in: Data("garbage".utf8))
                == TaskViewState(inProject: true))
    }

    @Test func aCorruptEntryDoesNotDiscardTheValidOnes() throws {
        var valid = TaskViewState(inProject: false)
        valid.sort = [TaskComparator(field: .due, order: .reverse)]
        let good = try #require(String(bytes: JSONEncoder().encode(valid), encoding: .utf8))
        let data = Data(#"{"tasks":\#(good),"p:bad":{"hidden":42},"p:worse":"nope"}"#.utf8)

        #expect(TaskViewStates.state(for: "tasks", inProject: false, in: data) == valid)
        #expect(TaskViewStates.state(for: "p:bad", inProject: true, in: data) == TaskViewState(inProject: true))
    }

    @Test func anUnknownSortFieldIsDroppedAndKeepsTheRest() throws {
        let known = try #require(String(bytes: JSONEncoder().encode(TaskComparator(field: .due)), encoding: .utf8))
        let unknown = known.replacingOccurrences(of: "\"due\"", with: "\"nonsense\"")
        let data = Data(#"{"tasks":{"hidden":["labels"],"sort":[\#(unknown),\#(known)]}}"#.utf8)

        let state = TaskViewStates.state(for: "tasks", inProject: false, in: data)

        #expect(state.sort == [TaskComparator(field: .due)])
        #expect(state.hidden == [.labels])
    }

    @Test func storingPrunesTheKeysOfProjectsThatNoLongerExist() {
        let alive = UUID()
        let gone = UUID()
        var data = Data()
        for key in [TaskViewStates.projectKey(alive), TaskViewStates.projectKey(gone), TaskViewStates.tasksKey] {
            data = TaskViewStates.storing(TaskViewState(inProject: true), for: key, in: data)
        }

        data = TaskViewStates.storing(
            TaskViewState(inProject: true), for: TaskViewStates.tasksKey, in: data, liveProjectIDs: [alive])

        let keys = Set(((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])?.keys.map { $0 } ?? [])
        #expect(keys == [TaskViewStates.projectKey(alive), TaskViewStates.tasksKey])
    }

    @Test func projectKeysUseTheProjectID() {
        let id = UUID()
        #expect(TaskViewStates.projectKey(id) == "p:\(id.uuidString)")
    }

    @Test func aStoredProjectStateWithoutHiddenUsesTheProjectDefaults() throws {
        var legacy = TaskViewState(inProject: false)
        legacy.sort = [TaskComparator(field: .due)]
        var object = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(legacy)) as? [String: Any])
        object["hidden"] = nil
        let data = try JSONSerialization.data(withJSONObject: ["p:1": object])

        let state = TaskViewStates.state(for: "p:1", inProject: true, in: data)
        #expect(state.hidden == TableColumnID.defaultHidden(inProject: true))
        #expect(state.sort == legacy.sort)
    }

    @Test func theTitleColumnIsNeverHiddenWhenLoading() {
        let data = Data(#"{"tasks":{"hidden":["title","labels"]}}"#.utf8)
        let state = TaskViewStates.state(for: "tasks", inProject: false, in: data)
        #expect(state.hidden == [.labels])
    }

    @Test func storedColumnPayloadSurvivesStoringAndRebuilding() throws {
        let payload = #"{"perColumnState":[{"base":{"explicit":{"_0":"title"}}},{"visibility":{"hidden":{}}}]}"#
        var state = TaskViewState(inProject: true)
        state.columns = Data(payload.utf8)

        let rebuilt = TableCustomization.make(from: state)
        #expect(rebuilt[visibility: TableColumnID.title.rawValue] == .hidden)

        var stored = TaskViewState(inProject: true)
        TableCustomization.store(rebuilt, into: &stored)
        #expect(TableCustomization.make(from: stored) == rebuilt)
        #expect(TableCustomization.make(from: stored)[visibility: TableColumnID.title.rawValue] == .hidden)
    }

    @Test func customizationCarriesTheHiddenColumnsBothWays() {
        let state = TaskViewState(inProject: true)
        var customization = TableCustomization.make(from: state)
        #expect(customization[visibility: TableColumnID.project.rawValue] == .hidden)
        #expect(customization[visibility: TableColumnID.status.rawValue] == .visible)

        customization[visibility: TableColumnID.labels.rawValue] = .hidden
        var restored = TaskViewState(inProject: false)
        TableCustomization.store(customization, into: &restored)
        #expect(restored.hidden == state.hidden.union([.labels]))
        #expect(restored.columns != nil)
    }

    @Test func legacyTableStateDecodesWithDefaults() throws {
        let json = Data(#"{"sort":[],"hidden":["labels"]}"#.utf8)
        let state = try JSONDecoder().decode(TaskViewState.self, from: json)

        #expect(state.query.isEmpty)
        #expect(state.filters.isEmpty)
        #expect(state.grouping == TaskViewGrouping.status)
        #expect(state.mode == nil)
        #expect(state.hidden == [.labels])
    }

    @Test func invalidNewFieldsFallBackToTheDefaults() throws {
        let json = Data(#"{"query":7,"filters":"x","grouping":"nonsense","mode":3}"#.utf8)
        let state = try JSONDecoder().decode(TaskViewState.self, from: json)

        #expect(state.query.isEmpty)
        #expect(state.filters.isEmpty)
        #expect(state.grouping == TaskViewGrouping.status)
        #expect(state.mode == nil)
    }

    @Test func aBrokenFilterIsDroppedAndKeepsTheRest() throws {
        let good = try #require(
            String(
                bytes: JSONEncoder().encode(TaskFilter(field: .status, values: ["done"])), encoding: .utf8))
        let json = Data(#"{"filters":[{"field":"nonsense"},\#(good)]}"#.utf8)
        let state = try JSONDecoder().decode(TaskViewState.self, from: json)

        #expect(state.filters == [TaskFilter(field: .status, values: ["done"])])
    }

    @Test func fullStateRoundTrips() throws {
        var state = TaskViewState(inProject: true)
        state.sort = [TaskComparator(field: .due, order: .reverse)]
        state.query = "invoice"
        state.filters = [TaskFilter(field: .status, op: .isNot, values: ["done"])]
        state.grouping = .priority
        state.mode = "board"

        let decoded = try JSONDecoder().decode(TaskViewState.self, from: JSONEncoder().encode(state))

        #expect(decoded == state)
        #expect(
            decoded.viewQuery.filters == state.filters && decoded.viewQuery.query == "invoice"
                && decoded.viewQuery.sort == state.sort.first)
    }

    @Test func migrationPrefersCurrentAndFallsBackToLegacy() {
        let current = Data("current".utf8)
        let legacy = Data("legacy".utf8)

        #expect(TaskViewStates.migrated(current: Data(), legacy: legacy) == legacy)
        #expect(TaskViewStates.migrated(current: current, legacy: legacy) == current)
        #expect(TaskViewStates.migrated(current: Data(), legacy: Data()).isEmpty)
        #expect(TaskViewStates.storageKey == "task.views" && TaskViewStates.legacyKey == "table.views")
    }

    @Test func pruningDropsDeadProjectsAndSavedViews() {
        let aliveProject = UUID()
        let goneProject = UUID()
        let aliveView = UUID()
        let goneView = UUID()
        let keys = [
            TaskViewStates.projectKey(aliveProject), TaskViewStates.projectKey(goneProject),
            TaskViewStates.savedViewKey(aliveView), TaskViewStates.savedViewKey(goneView),
            TaskViewStates.tasksKey, TaskViewStates.myTasksKey, TaskViewStates.calendarKey,
            TaskViewStates.timelineKey,
        ]
        var data = Data()
        for key in keys {
            data = TaskViewStates.storing(TaskViewState(inProject: false), for: key, in: data)
        }

        data = TaskViewStates.storing(
            TaskViewState(inProject: false), for: TaskViewStates.tasksKey, in: data,
            liveProjectIDs: [aliveProject], liveSavedViewIDs: [aliveView])

        let stored = Set(((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])?.keys.map { $0 } ?? [])
        #expect(stored == Set(keys).subtracting([keys[1], keys[3]]))
        #expect(TaskViewStates.savedViewKey(aliveView) == "sv:\(aliveView.uuidString)")
        #expect(
            [TaskViewStates.myTasksKey, TaskViewStates.calendarKey, TaskViewStates.timelineKey]
                == ["mytasks", "cal", "tl"])
    }

    @Test func phase2TableViewsSurviveMigration() throws {
        let suiteName = "tycho.migration.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let projectKey = TaskViewStates.projectKey(UUID())
        let widths = Data(#"{"perColumnState":[{"base":{"explicit":{"_0":"title"}}}]}"#.utf8)
        let comparator = try JSONSerialization.jsonObject(
            with: JSONEncoder().encode(TaskComparator(field: .due, order: .reverse)))
        let legacy: [String: Any] = [
            projectKey: ["sort": [comparator], "hidden": ["labels"], "columns": widths.base64EncodedString()],
            "tasks": 42,
        ]
        defaults.set(try JSONSerialization.data(withJSONObject: legacy), forKey: TaskViewStates.legacyKey)

        TaskViewStates.migrateStoredDefaults(defaults)

        let migrated = try #require(defaults.data(forKey: TaskViewStates.storageKey))
        let state = TaskViewStates.state(for: projectKey, inProject: true, in: migrated)
        #expect(state.sort == [TaskComparator(field: .due, order: .reverse)])
        #expect(state.columns == widths)
        #expect(state.hidden == [.labels])
        #expect(
            TaskViewStates.state(for: TaskViewStates.tasksKey, inProject: false, in: migrated)
                == TaskViewState(inProject: false))
    }
}
