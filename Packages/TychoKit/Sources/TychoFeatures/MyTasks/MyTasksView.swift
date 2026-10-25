import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct MyTasksView: View {
    @Query private var tasks: [TaskItem]

    var body: some View {
        let mine = tasks.filter { $0.assignee?.isMe == true && $0.project?.isArchived != true }
        Group {
            if mine.isEmpty {
                EmptyState(
                    title: "Nothing assigned to you", symbol: "checklist",
                    message: "Tasks assigned to you show up here.")
            } else {
                TaskListView(tasks: mine, project: nil)
            }
        }
        .background(Token.bg.color)
        .navigationTitle("My Tasks")
    }
}
