import SwiftUI
import TychoCore
import TychoDesign

struct TimelineTaskPane: View {
    let rows: [TimelineRow]
    @Binding var position: ScrollPosition

    var body: some View {
        VStack(spacing: 0) {
            Text("Task")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .frame(height: TimelineHeader.height)
            Divider()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(rows) { TimelineTaskRow(row: $0) }
                    Color.clear.frame(height: 40)
                }
            }
            .scrollPosition($position)
            .scrollDisabled(true)
            .scrollIndicators(.hidden)
        }
    }
}

struct TimelineTaskRow: View {
    @Environment(Router.self) private var router
    @Environment(\.isCompactWidth) private var isCompactWidth
    let row: TimelineRow

    var body: some View {
        Group {
            switch row {
            case .milestones(let count):
                header(Label("Milestones", systemImage: "diamond"), count: count)
            case .group(let group):
                header(
                    Label {
                        Text(group.title)
                    } icon: {
                        TimelineGroupIcon(kind: group.kind)
                    }, count: group.count)
            case .task(let task):
                Button {
                    router.inspect(task.id)
                } label: {
                    taskLabel(task)
                }
                .buttonStyle(.plain)
            }
        }
        .font(isCompactWidth ? .caption : .callout)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: TimelineLayout.rowHeight)
        .background(row.isHeader ? Color.primary.opacity(0.05) : Color.clear)
    }

    private func header(_ label: some View, count: Int) -> some View {
        HStack(spacing: 6) {
            label.fontWeight(.semibold).lineLimit(1)
            Text("\(count)").foregroundStyle(.secondary)
        }
    }

    private func taskLabel(_ task: TaskItem) -> some View {
        HStack(spacing: 8) {
            StatusIcon(glyph: task.status.glyph, color: task.status.tint, size: 13)
            Text(task.title)
                .lineLimit(1)
                .foregroundStyle(task.status == .done ? .secondary : .primary)
            Spacer(minLength: 0)
            if !isCompactWidth, let summary = TaskCard.subtaskSummary(task) {
                Text(summary).font(.caption2).monospacedDigit().foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

struct TimelineGroupIcon: View {
    let kind: TimelineGroupKind

    var body: some View {
        switch kind {
        case .status(let status): StatusIcon(glyph: status.glyph, color: status.tint, size: 13)
        case .member(let member): Avatar(initials: member.initials, color: member.tint, size: 16)
        case .unassigned: Image(systemName: "person.crop.circle.dashed").foregroundStyle(.secondary)
        case .project(let project): Circle().fill(project.color.tint).frame(width: 8, height: 8)
        case .all: EmptyView()
        }
    }
}
