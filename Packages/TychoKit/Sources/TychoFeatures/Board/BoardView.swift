import SwiftUI
import TychoCore
import TychoDesign

struct BoardView: View {
    let tasks: [TaskItem]
    let project: Project?
    let hiddenStatuses: Set<TaskStatus>

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: Spacing.s3) {
                ForEach(TaskGrouping.byStatus(tasks).filter { !hiddenStatuses.contains($0.status) }) { group in
                    BoardColumn(group: group, project: project, allTasks: tasks)
                }
            }
            .padding(Spacing.s4)
        }
        .scrollIndicators(.visible)
        .tychoAnimation(value: tasks.movementSignature)
    }
}
