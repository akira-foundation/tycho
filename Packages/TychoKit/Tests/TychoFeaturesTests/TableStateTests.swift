import Foundation
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TableStateTests {
    @Test func statesAreStoredPerKeyAndFallBackToTheDefaults() {
        var project = TableViewState(inProject: true)
        project.sort = [TaskComparator(field: .priority)]
        let data = TableViewStates.storing(project, for: "p:1", in: Data())

        #expect(TableViewStates.state(for: "p:1", inProject: true, in: data) == project)
        #expect(
            TableViewStates.state(for: TableViewStates.workspaceKey, inProject: false, in: data)
                == TableViewState(inProject: false))
        #expect(
            TableViewStates.state(for: "p:1", inProject: true, in: Data("garbage".utf8))
                == TableViewState(inProject: true))
    }

    @Test func onlyTheFirstSortComparatorIsPersisted() {
        let sort = [
            TaskComparator(field: .priority), TaskComparator(field: .title), TaskComparator(field: .due),
        ]
        let data = TableViewStates.storingSort(sort, for: "p:1", inProject: true, in: Data())
        let state = TableViewStates.state(for: "p:1", inProject: true, in: data)
        #expect(state.sort == [TaskComparator(field: .priority)])
    }

    @Test func aCorruptEntryDoesNotDiscardTheValidOnes() {
        var valid = TableViewState(inProject: false)
        valid.sort = [TaskComparator(field: .due, order: .reverse)]
        let good = String(decoding: try! JSONEncoder().encode(valid), as: UTF8.self)
        let data = Data(#"{"tasks":\#(good),"p:bad":{"hidden":42},"p:worse":"nope"}"#.utf8)

        #expect(TableViewStates.state(for: "tasks", inProject: false, in: data) == valid)
        #expect(TableViewStates.state(for: "p:bad", inProject: true, in: data) == TableViewState(inProject: true))
    }

    @Test func anUnknownSortFieldIsDroppedAndKeepsTheRest() throws {
        let known = String(decoding: try JSONEncoder().encode(TaskComparator(field: .due)), as: UTF8.self)
        let unknown = known.replacingOccurrences(of: "\"due\"", with: "\"nonsense\"")
        let data = Data(#"{"tasks":{"hidden":["labels"],"sort":[\#(unknown),\#(known)]}}"#.utf8)

        let state = TableViewStates.state(for: "tasks", inProject: false, in: data)

        #expect(state.sort == [TaskComparator(field: .due)])
        #expect(state.hidden == [.labels])
    }

    @Test func storingPrunesTheKeysOfProjectsThatNoLongerExist() {
        let alive = UUID()
        let gone = UUID()
        var data = Data()
        for key in [TableViewStates.projectKey(alive), TableViewStates.projectKey(gone), TableViewStates.workspaceKey] {
            data = TableViewStates.storing(TableViewState(inProject: true), for: key, in: data)
        }

        data = TableViewStates.storing(
            TableViewState(inProject: true), for: TableViewStates.workspaceKey, in: data, liveProjectIDs: [alive])

        let keys = Set(((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])?.keys.map { $0 } ?? [])
        #expect(keys == [TableViewStates.projectKey(alive), TableViewStates.workspaceKey])
    }

    @Test func projectKeysUseTheProjectID() {
        let id = UUID()
        #expect(TableViewStates.projectKey(id) == "p:\(id.uuidString)")
    }

    @Test func aStoredProjectStateWithoutHiddenUsesTheProjectDefaults() throws {
        var legacy = TableViewState(inProject: false)
        legacy.sort = [TaskComparator(field: .due)]
        var object = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(legacy)) as? [String: Any])
        object["hidden"] = nil
        let data = try JSONSerialization.data(withJSONObject: ["p:1": object])

        let state = TableViewStates.state(for: "p:1", inProject: true, in: data)
        #expect(state.hidden == TableColumnID.defaultHidden(inProject: true))
        #expect(state.sort == legacy.sort)
    }

    @Test func theTitleColumnIsNeverHiddenWhenLoading() {
        let data = Data(#"{"tasks":{"hidden":["title","labels"]}}"#.utf8)
        let state = TableViewStates.state(for: "tasks", inProject: false, in: data)
        #expect(state.hidden == [.labels])
    }

    @Test func customizationCarriesTheHiddenColumnsBothWays() {
        let state = TableViewState(inProject: true)
        var customization = TableCustomization.make(from: state)
        #expect(customization[visibility: TableColumnID.project.rawValue] == .hidden)
        #expect(customization[visibility: TableColumnID.status.rawValue] == .visible)

        customization[visibility: TableColumnID.labels.rawValue] = .hidden
        var restored = TableViewState(inProject: false)
        TableCustomization.store(customization, into: &restored)
        #expect(restored.hidden == state.hidden.union([.labels]))
        #expect(restored.columns != nil)
    }
}
