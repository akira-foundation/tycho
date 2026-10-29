import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TitleCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var editing = false
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: Spacing.s2) {
            StatusIcon(glyph: task.status.glyph, color: task.status.tint, size: 13)
            if editing {
                TextField("Title", text: $text)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .focusedOnceTheTableReleasesTheClick($focused)
                    .onSubmit(commit)
                    .onKeyPress(.escape) {
                        editing = false
                        return .handled
                    }
                    .onChange(of: focused) {
                        if !focused { commit() }
                    }
            } else {
                Text(task.title).lineLimit(1)
                Spacer(minLength: Spacing.s2)
                Text(task.key).tychoFont(.xxs, design: .monospaced).foregroundStyle(Token.text4.color)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: beginEditing)
        .onTapGesture { router.inspect(task.id) }
        .help("Double-click to rename")
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("table.title.\(task.key)")
    }

    private func beginEditing() {
        text = task.title
        editing = true
    }

    private func commit() {
        guard editing else { return }
        editing = false
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, text != task.title else { return }
        toast.perform { try TaskActions(context: context).rename(task, to: text) }
    }
}

struct StatusCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem

    var body: some View {
        Menu {
            ForEach(TaskStatus.allCases) { status in
                Button(status.title) { toast.perform { try TaskActions(context: context).setStatus(task, status) } }
            }
        } label: {
            HStack(spacing: Spacing.s1) {
                StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                Text(task.status.title)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityIdentifier("table.status.\(task.key)")
        .accessibilityValue(task.status.title)
    }
}

struct PriorityCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem

    var body: some View {
        Menu {
            ForEach(TaskPriority.allCases) { priority in
                Button(priority.title) {
                    toast.perform { try TaskActions(context: context).edit(task) { $0.priority = priority } }
                }
            }
        } label: {
            HStack(spacing: Spacing.s1) {
                PriorityIcon(weight: task.priority.weight)
                Text(task.priority.title)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityIdentifier("table.priority.\(task.key)")
    }
}

struct AssigneeCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    let members: [Member]

    var body: some View {
        Menu {
            Button("Unassigned") { assign(nil) }
            ForEach(members) { member in
                Button(member.name) { assign(member) }
            }
        } label: {
            HStack(spacing: Spacing.s1) {
                if let assignee = task.assignee {
                    Avatar(initials: assignee.initials, color: assignee.tint, size: 18)
                }
                Text(task.assignee?.name ?? "Unassigned")
                    .foregroundStyle(task.assignee == nil ? Token.text4.color : Token.text.color)
                    .lineLimit(1)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }

    private func assign(_ member: Member?) {
        toast.perform { try TaskActions(context: context).edit(task) { $0.assignee = member } }
    }
}

struct CreatedCell: View {
    @Environment(\.dateText) private var dateText
    let task: TaskItem

    var body: some View {
        Text(dateText.short(task.createdAt)).monospacedDigit().foregroundStyle(Token.text3.color)
    }
}

struct ProjectCell: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: Spacing.s1) {
            Circle().fill(task.project?.color.tint ?? Token.gray.color).frame(width: 8, height: 8)
            Text(task.project?.name ?? "—").lineLimit(1)
        }
    }
}

struct TableGroupHeader: View {
    let status: TaskStatus
    let count: Int

    var body: some View {
        HStack(spacing: Spacing.s2) {
            StatusIcon(glyph: status.glyph, color: status.tint)
            Text(status.title).tychoFont(.sm, weight: .semibold)
            Text("\(count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
        }
    }
}
