import Foundation
import Testing

@testable import TychoCore

struct BoardStatusVisibilityTests {
    @Test func everyStatusIsVisibleByDefault() {
        #expect(TaskViewState(inProject: true).visibleStatuses == TaskStatus.allCases)
    }

    @Test func hidingAndShowingAStatusUpdatesTheVisibleStatuses() {
        var state = TaskViewState(inProject: true)
        state.setVisible(false, for: .review)
        state.setVisible(false, for: .backlog)
        #expect(state.visibleStatuses == [.todo, .progress, .done])
        state.setVisible(true, for: .backlog)
        #expect(state.visibleStatuses == [.backlog, .todo, .progress, .done])
    }

    @Test func theLastVisibleStatusCannotBeHidden() {
        var state = TaskViewState(inProject: true)
        for status in TaskStatus.allCases {
            state.setVisible(false, for: status)
        }
        #expect(state.visibleStatuses == [.done])
    }

    @Test func hiddenStatusesRoundTripAndToleratesUnknownOnes() throws {
        var state = TaskViewState(inProject: true)
        state.hiddenStatuses = [.done, .backlog]
        let decoded = try JSONDecoder().decode(TaskViewState.self, from: JSONEncoder().encode(state))
        #expect(decoded.hiddenStatuses == [.done, .backlog])

        let json = Data(#"{"hiddenStatuses":["review","archived"]}"#.utf8)
        #expect(try JSONDecoder().decode(TaskViewState.self, from: json).hiddenStatuses == [.review])
        #expect(try JSONDecoder().decode(TaskViewState.self, from: Data("{}".utf8)).hiddenStatuses.isEmpty)
    }
}
