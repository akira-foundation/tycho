import SwiftUI
import TychoCore
import TychoDesign

struct TaskRow: View {
    @Environment(Router.self) private var router
    @Environment(\.density) private var density
    @Environment(\.isCompactWidth) private var isCompactWidth
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
                if isCompactWidth {
                    VStack(alignment: .leading, spacing: 2) {
                        title.lineLimit(2)
                        HStack(spacing: Spacing.s2) {
                            key
                            DueText(task: task)
                        }
                    }
                } else {
                    key
                    title.lineLimit(1)
                }
                Spacer(minLength: Spacing.s2)
                if !isCompactWidth {
                    ForEach(TaskLabel.allCases.filter(task.labels.contains)) { label in
                        LabelPill(title: label.title, color: label.tint)
                    }
                    PriorityIcon(weight: task.priority.weight)
                    DueText(task: task)
                }
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

    private var key: some View {
        Text(task.key)
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
    }

    private var title: some View {
        Text(task.title)
            .font(.body)
            .foregroundStyle(task.status == .done ? .secondary : .primary)
            .strikethrough(task.status == .done)
    }
}

struct DueText: View {
    let task: TaskItem
    @Environment(\.dateText) private var dateText

    var body: some View {
        if let due = task.due {
            Text(dateText.short(due))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(
                    task.isOverdue(now: .now, calendar: .current) ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
        }
    }
}
