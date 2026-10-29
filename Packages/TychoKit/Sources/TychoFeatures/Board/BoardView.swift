import SwiftUI
import TychoCore
import TychoDesign

struct BoardView: View {
    let tasks: [TaskItem]
    let project: Project?
    @State private var collapsed: Set<TaskStatus> = []

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: Spacing.s3) {
                ForEach(TaskGrouping.byStatus(tasks)) { group in
                    BoardColumn(
                        group: group,
                        project: project,
                        allTasks: tasks,
                        collapsed: Binding(
                            get: { collapsed.contains(group.status) },
                            set: { if $0 { collapsed.insert(group.status) } else { collapsed.remove(group.status) } }
                        )
                    )
                }
            }
            .padding(Spacing.s4)
        }
        .scrollIndicators(.visible)
        .tychoAnimation(value: tasks.movementSignature)
    }
}
