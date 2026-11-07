import SwiftUI
import TychoCore

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
        let done = task.status == .done
        HStack(spacing: 4) {
            Circle().fill(task.project?.color.tint ?? .gray).frame(width: 6, height: 6)
            Text(task.title).lineLimit(1).strikethrough(done)
            Spacer(minLength: 0)
        }
        .font(.caption)
        .foregroundStyle(done ? .secondary : .primary)
        .frame(height: 18)
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
            HStack(spacing: 4) {
                Circle().fill(event.project?.color.tint ?? .gray).frame(width: 6, height: 6)
                Text(event.title).lineLimit(1)
                Spacer(minLength: 0)
                Text(event.time).monospacedDigit().foregroundStyle(.secondary)
            }
            .font(.caption)
            .frame(height: 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("\(event.title) · \(event.time)")
        .popover(isPresented: $showing) { EventPopover(event: event) }
        .accessibilityIdentifier("calendar.event.\(event.title)")
    }
}
