import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct MyTasksModeTests {
    @Test func myTasksOffersListBoardTableAndCalendar() {
        #expect(MyTasksMode.allCases.map(\.title) == ["List", "Board", "Table", "Calendar"])
        let layouts: [ProjectBuiltInTab] = [.list, .board, .table, .calendar]
        #expect(MyTasksMode.allCases.map(\.symbol) == layouts.map(\.symbol))
    }

    @Test func myTasksOpensAsAListByDefault() {
        #expect(MyTasksMode(state: TaskViewState(inProject: false)) == .list)
    }

    @Test func myTasksModeComesFromTheViewState() {
        var state = TaskViewState(inProject: false)
        state.mode = "calendar"
        #expect(MyTasksMode(state: state) == .calendar)
        state.mode = "board"
        #expect(MyTasksMode(state: state) == .board)
        state.mode = "timeline"
        #expect(MyTasksMode(state: state) == .list)
    }

    @Test func theTasksPageKeepsItsThreeModes() {
        var state = TaskViewState(inProject: false)
        state.mode = "calendar"
        #expect(TasksMode(state: state) == .list)
        #expect(TasksMode.allCases.count == 3)
    }

    @MainActor
    @Test func theOldTasksPreferenceLeavesMyTasksAlone() throws {
        let defaults = try ScratchDefaults.numbered("my-tasks-mode").defaults
        defaults.set("board", forKey: TasksMode.legacyKey)

        TasksMode.migrateLegacyPreference(defaults)
        let model = TaskViewModel(key: TaskViewStates.myTasksKey, inProject: false, defaults: defaults)

        #expect(MyTasksMode(state: model.state) == .list)
    }

    @MainActor
    @Test func theChosenModeIsKeptPerView() throws {
        let defaults = try ScratchDefaults.numbered("my-tasks-mode").defaults
        let model = TaskViewModel(key: TaskViewStates.myTasksKey, inProject: false, defaults: defaults)

        model.state.mode = MyTasksMode.calendar.rawValue
        let reopened = TaskViewModel(key: TaskViewStates.myTasksKey, inProject: false, defaults: defaults)
        let tasks = TaskViewModel(key: TaskViewStates.tasksKey, inProject: false, defaults: defaults)

        #expect(MyTasksMode(state: reopened.state) == .calendar)
        #expect(TasksMode(state: tasks.state) == .list)
    }
}
