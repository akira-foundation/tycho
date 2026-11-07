import SwiftUI
import TychoCore

struct WeekTaskCard: View {
    @Environment(Router.self) private var router
    let task: TaskItem

    var body: some View {
        let done = task.status == .done
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle().fill(task.project?.color.tint ?? .gray).frame(width: 6, height: 6)
                Text(task.title).lineLimit(2).strikethrough(done)
            }
            .font(.callout)
            .foregroundStyle(done ? .secondary : .primary)
            Text(task.project?.name ?? task.key).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 6))
        .contentShape(Rectangle())
        .onTapGesture { router.inspect(task.id) }
        .draggable(TaskTransfer(id: task.id))
        .contextMenu { TaskMenu(task: task) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("calendar.card.\(task.key)")
    }
}

struct WeekEventCard: View {
    let event: CalendarEvent
    @State private var showing = false

    var body: some View {
        Button {
            showing = true
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Circle().fill(event.project?.color.tint ?? .gray).frame(width: 6, height: 6)
                    Text(event.title).lineLimit(2)
                }
                .font(.callout)
                Text(event.time).font(.caption).monospacedDigit().foregroundStyle(.secondary)
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .themedPopover(isPresented: $showing) { EventPopover(event: event) }
    }
}
