import SwiftUI
import TychoCore
import TychoDesign

struct TaskRow: View {
    @Environment(Router.self) private var router
    @Environment(\.density) private var density
    let task: TaskItem
    var showsProject = false

    var body: some View {
        Button {
            router.inspect(task.id)
        } label: {
            HStack(spacing: Spacing.s2) {
                StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                if showsProject, let project = task.project {
                    ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 16)
                }
                Text(task.key)
                    .tychoFont(.xs, design: .monospaced)
                    .foregroundStyle(Token.text4.color)
                Text(task.title)
                    .tychoFont(.base)
                    .foregroundStyle(task.status == .done ? Token.text3.color : Token.text.color)
                    .strikethrough(task.status == .done, color: Token.text4.color)
                    .lineLimit(1)
                Spacer(minLength: Spacing.s2)
                ForEach(TaskLabel.allCases.filter(task.labels.contains)) { label in
                    LabelPill(title: label.title, color: label.tint)
                }
                PriorityIcon(weight: task.priority.weight)
                DueText(task: task)
                if let assignee = task.assignee {
                    Avatar(initials: assignee.initials, color: assignee.tint)
                }
            }
            .frame(minHeight: density.metrics.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("task.\(task.key)")
    }
}

struct DueText: View {
    let task: TaskItem

    var body: some View {
        if let due = task.due {
            Text(due, format: .dateTime.month(.abbreviated).day())
                .tychoFont(.xs)
                .monospacedDigit()
                .foregroundStyle(task.isOverdue(now: .now, calendar: .current) ? Token.red.color : Token.text3.color)
        }
    }
}
