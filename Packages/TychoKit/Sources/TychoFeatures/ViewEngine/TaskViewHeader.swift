import SwiftUI
import TychoCore

struct TaskViewEngine {
    let model: TaskViewModel
    let members: [Member]
    let projects: [Project]
}

struct TaskViewHeader<Trailing: View>: View {
    let engine: TaskViewEngine
    let showsGroup: Bool
    let showsColumns: Bool
    let trailing: Trailing

    init(
        engine: TaskViewEngine, showsGroup: Bool = false, showsColumns: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.engine = engine
        self.showsGroup = showsGroup
        self.showsColumns = showsColumns
        self.trailing = trailing()
    }

    var body: some View {
        VStack(spacing: 0) {
            TaskViewToolbar(
                model: engine.model, showsGroup: showsGroup, showsColumns: showsColumns, members: engine.members,
                projects: engine.projects
            ) { trailing }
            FilterChips(model: engine.model, members: engine.members, projects: engine.projects)
            Divider()
        }
    }
}
