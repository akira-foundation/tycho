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
        #if os(macOS)
        VStack(alignment: .leading, spacing: Spacing.s3) {
            Text(dateText.long(day))
                .font(.headline)
                .accessibilityIdentifier("calendar.daylist.title")
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s3) {
                    ForEach(items) { row($0) }
                }
            }
            .frame(maxHeight: 320)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("calendar.daylist")
        }
        .padding()
        .frame(width: 300, alignment: .leading)
        #else
        NavigationStack {
            List(items) { row($0) }
                .accessibilityIdentifier("calendar.daylist")
                .navigationTitle(dateText.long(day))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) { dismiss() }
                    }
                }
        }
        .presentationDetents([.medium, .large])
        #endif
    }

    @ViewBuilder private func row(_ item: CalendarItem) -> some View {
        switch item {
        case .event(let event):
            Button {
                if let id = event.project?.id { router.openProject(id, tab: .calendar) }
            } label: {
                DayListRow(trailing: event.time) {
                    Label(event.title, systemImage: "clock")
                }
            }
            .buttonStyle(.plain)
        case .task(let task):
            Button {
                router.inspect(task.id)
            } label: {
                DayListRow(trailing: task.assignee?.name ?? "") {
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

private struct DayListRow<Leading: View>: View {
    let trailing: String
    @ViewBuilder let leading: Leading

    var body: some View {
        HStack(spacing: Spacing.s2) {
            leading.lineLimit(1).layoutPriority(1)
            Spacer(minLength: Spacing.s2)
            Text(trailing).monospacedDigit().foregroundStyle(.secondary).lineLimit(1)
        }
        .contentShape(Rectangle())
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
