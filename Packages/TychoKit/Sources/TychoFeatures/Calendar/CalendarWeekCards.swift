import SwiftUI
import TychoCore
import TychoDesign

struct WeekTaskCard: View {
    @Environment(Router.self) private var router
    let task: TaskItem

    var body: some View {
        let tint = task.project?.color.tint ?? Token.gray.color
        let done = task.status == .done
        VStack(alignment: .leading, spacing: Spacing.s1) {
            HStack(spacing: Spacing.s1) {
                Circle().fill(tint).frame(width: 6, height: 6)
                Text(task.title)
                    .lineLimit(2)
                    .strikethrough(done)
                    .foregroundStyle(done ? Token.text3.color : Token.text.color)
            }
            .tychoFont(.xs, weight: .medium)
            HStack(spacing: Spacing.s1) {
                StatusIcon(glyph: task.status.glyph, color: task.status.tint, size: 11)
                PriorityIcon(weight: task.priority.weight, size: 11)
                Text(task.project?.name ?? "").lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                if let assignee = task.assignee {
                    Avatar(initials: assignee.initials, color: assignee.tint, size: 16)
                }
            }
            .tychoFont(.xxs)
            .foregroundStyle(Token.text3.color)
        }
        .padding(Spacing.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.sm))
        .overlay(alignment: .leading) { Rectangle().fill(tint).frame(width: 2) }
        .shadowCard()
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
            VStack(alignment: .leading, spacing: Spacing.s1) {
                HStack(spacing: Spacing.s1) {
                    Circle().fill(event.project?.color.tint ?? Token.gray.color).frame(width: 6, height: 6)
                    Text(event.title).lineLimit(2)
                }
                .tychoFont(.xs, weight: .medium)
                Label("\(event.time) · \(event.project?.name ?? "")", systemImage: "clock")
                    .tychoFont(.xxs)
                    .foregroundStyle(Token.text3.color)
            }
            .padding(Spacing.s2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Token.sunken.color, in: RoundedRectangle(cornerRadius: Radius.sm))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showing) { EventPopover(event: event) }
    }
}
