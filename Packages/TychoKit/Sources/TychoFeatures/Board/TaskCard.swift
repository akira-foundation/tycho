import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskCard: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Environment(\.density) private var density
    let task: TaskItem

    static func subtaskSummary(_ task: TaskItem) -> String? {
        let all = task.subtasks ?? []
        guard !all.isEmpty else { return nil }
        return "\(all.filter(\.isDone).count)/\(all.count)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack(alignment: .top, spacing: Spacing.s2) {
                Button {
                    toast.perform { try TaskActions(context: context).toggleDone(task) }
                } label: {
                    StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.status == .done ? "Reopen" : "Mark complete")
                .accessibilityIdentifier("card.\(task.key).toggle")
                Text(task.title)
                    .tychoFont(.base, weight: .medium)
                    .foregroundStyle(task.status == .done ? Token.text3.color : Token.text.color)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { router.inspect(task.id) }
            }
            let labels = TaskLabel.allCases.filter(task.labels.contains)
            if !labels.isEmpty {
                FlowRow(labels: labels)
            }
            footer
        }
        .padding(density.metrics.cardPadding)
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .shadowCard()
        .contentShape(Rectangle())
        .onTapGesture { router.inspect(task.id) }
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: "Open") { router.inspect(task.id) }
        .accessibilityIdentifier("card.\(task.key)")
    }

    private var footer: some View {
        HStack(spacing: Spacing.s2) {
            Text(task.key).tychoFont(.xxs, design: .monospaced).foregroundStyle(Token.text4.color)
            PriorityIcon(weight: task.priority.weight, size: 12)
            if let summary = Self.subtaskSummary(task) {
                Label(summary, systemImage: "checklist").tychoFont(.xxs).foregroundStyle(Token.text3.color)
            }
            Spacer()
            DueText(task: task)
            if let assignee = task.assignee {
                Avatar(initials: assignee.initials, color: assignee.tint, size: 20)
            }
        }
    }
}

struct FlowRow: View {
    let labels: [TaskLabel]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.s1) { pills }
            VStack(alignment: .leading, spacing: Spacing.s1) { pills }
        }
    }

    private var pills: some View {
        ForEach(labels) { LabelPill(title: $0.title, color: $0.tint) }
    }
}
