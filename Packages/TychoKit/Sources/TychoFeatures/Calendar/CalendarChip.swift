import SwiftUI
import TychoCore
import TychoDesign

struct CalendarChip: View {
    let item: CalendarItem

    var body: some View {
        switch item {
        case .event(let event): EventChip(event: event)
        case .task(let task): TaskChip(task: task)
        }
    }
}

struct TaskChip: View {
    @Environment(Router.self) private var router
    let task: TaskItem

    var body: some View {
        let tint = task.project?.color.tint ?? Token.gray.color
        let done = task.status == .done
        HStack(spacing: Spacing.s1) {
            if done {
                StatusIcon(glyph: .done, color: TaskStatus.done.tint, size: 11)
            } else {
                PriorityIcon(weight: task.priority.weight, size: 11)
            }
            Text(task.title).lineLimit(1).strikethrough(done)
            Spacer(minLength: 0)
            if let assignee = task.assignee {
                Avatar(initials: assignee.initials, color: assignee.tint, size: 14)
            }
        }
        .tychoFont(.xxs, weight: .medium)
        .foregroundStyle(done ? Token.text3.color : Token.text.color)
        .padding(.horizontal, Spacing.s1)
        .frame(height: 20)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.xs))
        .overlay(alignment: .leading) { Rectangle().fill(tint).frame(width: 2) }
        .opacity(done ? 0.7 : 1)
        .contentShape(Rectangle())
        .onTapGesture { router.inspect(task.id) }
        .draggable(TaskTransfer(id: task.id))
        .contextMenu { TaskMenu(task: task) }
        .help(task.title)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("calendar.chip.\(task.key)")
    }
}

struct EventChip: View {
    let event: CalendarEvent
    @State private var showing = false

    var body: some View {
        Button {
            showing = true
        } label: {
            HStack(spacing: Spacing.s1) {
                Text(event.time).monospacedDigit().foregroundStyle(Token.text4.color)
                Text(event.title).lineLimit(1)
                Spacer(minLength: 0)
            }
            .tychoFont(.xxs, weight: .medium)
            .padding(.horizontal, Spacing.s1)
            .frame(height: 20)
            .background(
                (event.project?.color.tint ?? Token.gray.color).opacity(0.18),
                in: RoundedRectangle(cornerRadius: Radius.xs)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("\(event.title) · \(event.time)")
        .popover(isPresented: $showing) { EventPopover(event: event) }
        .accessibilityIdentifier("calendar.event.\(event.title)")
    }
}
