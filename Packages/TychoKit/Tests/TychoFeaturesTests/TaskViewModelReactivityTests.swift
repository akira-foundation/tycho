import Foundation
import Observation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct TaskViewModelReactivityTests {
    private func makeDefaults() throws -> UserDefaults {
        try ScratchDefaults.numbered("task-view-model-reactivity").defaults
    }

    @Test func aWriteFromAnotherModelNotifiesObservers() throws {
        let defaults = try makeDefaults()
        let first = TaskViewModel(key: "tasks", inProject: false, defaults: defaults)
        let second = TaskViewModel(key: "tasks", inProject: false, defaults: defaults)
        let fired = Flag()
        withObservationTracking {
            _ = first.state
        } onChange: {
            fired.value = true
        }

        second.setQuery("x")

        #expect(fired.value)
        #expect(first.state.query == "x")
    }

    @Test func aDirectWriteToTheStoredBlobNotifiesObservers() throws {
        let defaults = try makeDefaults()
        let model = TaskViewModel(key: "tasks", inProject: false, defaults: defaults)
        let fired = Flag()
        withObservationTracking {
            _ = model.state
        } onChange: {
            fired.value = true
        }

        var external = TaskViewState(inProject: false)
        external.sort = [TaskComparator(field: .due, order: .reverse)]
        defaults.set(TaskViewStates.storing(external, for: "tasks", in: Data()), forKey: TaskViewStates.storageKey)

        #expect(fired.value)
        #expect(model.state == external)
    }

    @Test func aWriteToAnotherKeyDoesNotNotify() throws {
        let defaults = try makeDefaults()
        let model = TaskViewModel(key: "tasks", inProject: false, defaults: defaults)
        let other = TaskViewModel(key: "mytasks", inProject: false, defaults: defaults)
        let fired = Flag()
        withObservationTracking {
            _ = model.state
        } onChange: {
            fired.value = true
        }

        other.setQuery("elsewhere")

        #expect(!fired.value)
    }
}

private final class Flag: @unchecked Sendable {
    var value = false
}
