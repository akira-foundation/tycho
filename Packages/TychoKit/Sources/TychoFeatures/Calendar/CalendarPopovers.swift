import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct DayListPopover: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    @Environment(\.dismiss) private var dismiss
    @Query private var tasks: [TaskItem]
    @Query(sort: \CalendarEvent.time) private var events: [CalendarEvent]
    let day: Date

    var body: some View {
        let items = CalendarDay.items(
            on: day, events: events.inLiveProjects(),
            tasks: tasks.inLiveProjects(), calendar: DateText.gregorian)
        NavigationStack {
            List(items) { row($0) }
                .accessibilityIdentifier("calendar.daylist")
                .navigationTitle(dateText.long(day))
                #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
                #endif
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #else
        .frame(width: 300, height: 260)
        #endif
    }

    @ViewBuilder private func row(_ item: CalendarItem) -> some View {
        switch item {
        case .event(let event):
            Button {
                if let id = event.project?.id { router.openProject(id, tab: .calendar) }
            } label: {
                LabeledContent {
                    Text(event.time).monospacedDigit()
                } label: {
                    Label(event.title, systemImage: "clock")
                }
            }
            .buttonStyle(.plain)
        case .task(let task):
            Button {
                router.inspect(task.id)
            } label: {
                LabeledContent {
                    Text(task.assignee?.name ?? "")
                } label: {
                    Label {
                        Text(task.title)
                    } icon: {
                        StatusIcon(glyph: task.status.glyph, color: task.status.tint)
                    }
                }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle().fill(event.project?.color.tint ?? .gray).frame(width: 8, height: 8)
                Text(event.title).font(.headline)
            }
            VStack(alignment: .leading, spacing: 4) {
                Label("\(event.date.map(dateText.long) ?? "") · \(event.time)", systemImage: "calendar")
                if let project = event.project {
                    Label(project.name, systemImage: "folder")
                    HStack(spacing: 8) {
                        Image(systemName: "person.2")
                        AvatarStack(people: (project.members ?? []).map { ($0.initials, $0.tint) }, limit: 5)
                    }
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            Divider()
            Button("Open Project", systemImage: "arrow.up.right") {
                if let id = event.project?.id { router.openProject(id, tab: .board) }
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(width: 270, alignment: .leading)
    }
}
