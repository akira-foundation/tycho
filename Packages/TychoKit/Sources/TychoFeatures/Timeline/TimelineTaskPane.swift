import SwiftUI
import TychoCore
import TychoDesign

struct TimelineTaskPane: View {
    let rows: [TimelineRow]
    @Binding var position: ScrollPosition

    var body: some View {
        VStack(spacing: 0) {
            Text("Task")
                .tychoFont(.xs, weight: .semibold)
                .foregroundStyle(Token.text3.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.s3)
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
    let row: TimelineRow

    var body: some View {
        Group {
            switch row {
            case .milestones(let count):
                HStack(spacing: Spacing.s2) {
                    Image(systemName: "diamond")
                    Text("Milestones").tychoFont(.sm, weight: .semibold)
                    Text("\(count)").foregroundStyle(Token.text4.color)
                }
            case .group(let group):
                HStack(spacing: Spacing.s2) {
                    TimelineGroupIcon(kind: group.kind)
                    Text(group.title).tychoFont(.sm, weight: .semibold).lineLimit(1)
                    Text("\(group.count)").foregroundStyle(Token.text4.color)
                }
            case .task(let task):
                Button {
                    router.inspect(task.id)
                } label: {
                    taskLabel(task)
                }
                .buttonStyle(.plain)
            }
        }
        .tychoFont(.sm)
        .padding(.horizontal, Spacing.s3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: TimelineLayout.rowHeight)
        .background(row.isHeader ? Token.sunken.color : Color.clear)
    }

    private func taskLabel(_ task: TaskItem) -> some View {
        HStack(spacing: Spacing.s2) {
            StatusIcon(glyph: task.status.glyph, color: task.status.tint, size: 13)
            Text(task.title)
                .lineLimit(1)
                .foregroundStyle(task.status == .done ? Token.text3.color : Token.text.color)
            Spacer(minLength: 0)
            if let summary = TaskCard.subtaskSummary(task) {
                Text(summary).tychoFont(.xxs).monospacedDigit().foregroundStyle(Token.text4.color)
            }
            if let assignee = task.assignee {
                Avatar(initials: assignee.initials, color: assignee.tint, size: 18)
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
        case .unassigned: Image(systemName: "person.crop.circle.dashed").foregroundStyle(Token.text4.color)
        case .project(let project): Circle().fill(project.color.tint).frame(width: 8, height: 8)
        case .all: EmptyView()
        }
    }
}
