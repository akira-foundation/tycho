import SwiftUI
import TychoCore
import TychoDesign

struct TableCardList: View {
    @Environment(Router.self) private var router
    let tasks: [TaskItem]

    var body: some View {
        List(tasks) { task in
            Button {
                router.inspect(task.id)
            } label: {
                VStack(alignment: .leading, spacing: Spacing.s2) {
                    HStack(spacing: Spacing.s2) {
                        StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                        Text(task.title).tychoFont(.base, weight: .medium).lineLimit(2)
                        Spacer()
                        Text(task.key).tychoFont(.xxs, design: .monospaced).foregroundStyle(Token.text4.color)
                    }
                    HStack(spacing: 10) {
                        HStack(spacing: Spacing.s1) {
                            PriorityIcon(weight: task.priority.weight, size: 12)
                            Text(task.priority.title)
                        }
                        if let assignee = task.assignee {
                            Avatar(initials: assignee.initials, color: assignee.tint, size: 18)
                        }
                        Text(task.assignee?.name ?? "Unassigned").foregroundStyle(Token.text3.color)
                        DueText(task: task)
                        if let estimate = task.estimate {
                            Label(estimate, systemImage: "timer").foregroundStyle(Token.text4.color)
                        }
                    }
                    .tychoFont(.xs)
                }
                .padding(.vertical, Spacing.s1)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
}
