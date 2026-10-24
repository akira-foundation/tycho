import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct DayListPopover: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    @Query private var tasks: [TaskItem]
    @Query(sort: \CalendarEvent.time) private var events: [CalendarEvent]
    let day: Date

    var body: some View {
        let items = CalendarDay.items(
            on: day, events: events.inLiveProjects(),
            tasks: tasks.inLiveProjects(), calendar: DateText.gregorian)
        VStack(alignment: .leading, spacing: Spacing.s1) {
            Text(dateText.long(day)).tychoFont(.xs, weight: .semibold).foregroundStyle(Token.text3.color)
            ForEach(items) { row($0) }
        }
        .padding(Spacing.s2)
        .frame(width: 280, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calendar.daylist")
    }

    @ViewBuilder private func row(_ item: CalendarItem) -> some View {
        switch item {
        case .event(let event):
            Button {
                if let id = event.project?.id { router.openProject(id, tab: .calendar) }
            } label: {
                HStack(spacing: Spacing.s2) {
                    Label(event.title, systemImage: "clock").lineLimit(1)
                    Spacer()
                    Text(event.time).monospacedDigit().foregroundStyle(Token.text3.color)
                }
                .frame(height: 28)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        case .task(let task):
            Button {
                router.inspect(task.id)
            } label: {
                HStack(spacing: Spacing.s2) {
                    StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                    Text(task.title).lineLimit(1)
                    Spacer()
                    if let assignee = task.assignee {
                        Avatar(initials: assignee.initials, color: assignee.tint, size: 18)
                    }
                }
                .frame(height: 28)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct EventPopover: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack(spacing: Spacing.s2) {
                Circle().fill(event.project?.color.tint ?? Token.gray.color).frame(width: 8, height: 8)
                Text(event.title).tychoFont(.md, weight: .semibold)
            }
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Label("\(event.date.map(dateText.long) ?? "") · \(event.time)", systemImage: "calendar")
                if let project = event.project {
                    Label(project.name, systemImage: "folder")
                    HStack(spacing: Spacing.s2) {
                        Image(systemName: "person.2")
                        AvatarStack(people: (project.members ?? []).map { ($0.initials, $0.tint) }, limit: 5)
                    }
                }
            }
            .tychoFont(.sm)
            .foregroundStyle(Token.text3.color)
            Divider()
            Button("Open project", systemImage: "arrow.up.right") {
                if let id = event.project?.id { router.openProject(id, tab: .board) }
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.s3)
        .frame(width: 270, alignment: .leading)
    }
}
