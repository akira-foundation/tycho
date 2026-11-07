import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    @Query private var tasks: [TaskItem]
    @State private var tab = HomeTab.upcoming

    private var summary: HomeSummary {
        HomeSummary(projects: projects, tasks: tasks, now: .now, calendar: .current)
    }

    var body: some View {
        let summary = summary
        Form {
            Section { stats(summary) }
            myTasks(summary)
            projectProgress
            HomeDeadlines(buckets: summary.deadlines)
        }
        .formStyle(.grouped)
        .navigationTitle("Home")
        .navigationSubtitle(
            Self.subtitle(name: workspaces.first?.me?.firstName ?? "", now: .now, dateText: dateText)
        )
        .toolbar {
            ToolbarItem { Button("New Project", systemImage: "folder.badge.plus") { router.newProject() } }
            ToolbarItem { Button("New Task", systemImage: "plus") { router.newTask() } }
        }
    }

    static func subtitle(name: String, now: Date, dateText: DateText) -> String {
        let greeting = Greeting.text(hour: DateText.gregorian.component(.hour, from: now))
        let salutation = name.isEmpty ? greeting : "\(greeting), \(name)"
        return "\(salutation) · \(dateText.weekdayMonthDay(now))"
    }

    private func stats(_ summary: HomeSummary) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], alignment: .leading, spacing: 16) {
            StatCard(
                title: "Active Projects", symbol: "folder", value: "\(summary.activeProjects)",
                detail: "\(summary.projectsAtRisk) at risk", tone: nil
            ) {
                router.open(.projects)
            }
            StatCard(
                title: "Open Tasks", symbol: "circle.dashed", value: "\(summary.openTasks)",
                detail: "\(summary.openAssignedToMe) assigned to you", tone: nil
            ) {
                router.openTasks(preset: .open)
            }
            StatCard(
                title: "Completed", symbol: "checkmark.circle", value: "\(summary.completedThisWeek)",
                detail: "this week", tone: nil
            ) {
                router.openTasks(preset: .done)
            }
            StatCard(
                title: "Overdue",
                symbol: "clock.badge.exclamationmark",
                value: "\(summary.overdue)",
                detail: summary.overdue > 0 ? "need attention" : "all on track",
                tone: summary.overdue > 0 ? .red : nil
            ) {
                router.openTasks(preset: .overdue)
            }
        }
        .padding(.vertical, 4)
    }

    private func myTasks(_ summary: HomeSummary) -> some View {
        Section("My Tasks") {
            Picker("Tasks", selection: $tab) {
                ForEach(HomeTab.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            let list = tab.tasks(in: summary)
            if list.isEmpty {
                Text("Nothing Here").foregroundStyle(.secondary)
            } else {
                ForEach(list) { TaskRow(task: $0, showsProject: true) }
            }
        }
    }

    private var projectProgress: some View {
        Section("Project Progress") {
            ForEach(projects.filter { !$0.isArchived && $0.status != .complete }) { project in
                Button {
                    router.openProject(project.id, tab: .board)
                } label: {
                    LabeledContent {
                        HStack(spacing: 8) {
                            ProgressView(value: Double(project.progress), total: 100)
                                .tint(project.color.tint)
                                .frame(width: 60)
                            Text("\(project.progress)%").monospacedDigit().frame(minWidth: 36, alignment: .trailing)
                        }
                    } label: {
                        Label {
                            Text(project.name).lineLimit(1)
                        } icon: {
                            ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 18)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HomeDeadlines: View {
    @Environment(Router.self) private var router
    let buckets: [DeadlineBucket]

    var body: some View {
        ForEach(buckets) { bucket in
            Section {
                if bucket.tasks.isEmpty {
                    Text("Nothing Due").foregroundStyle(.secondary)
                }
                ForEach(bucket.tasks.prefix(4)) { row($0) }
                if bucket.tasks.count > 4 {
                    Text("\(bucket.tasks.count - 4) more").font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                HStack {
                    Text("Due \(bucket.title.capitalized)")
                    Spacer()
                    Text("\(bucket.tasks.count)").monospacedDigit()
                }
            }
        }
    }

    private func row(_ task: TaskItem) -> some View {
        Button {
            router.inspect(task.id)
        } label: {
            LabeledContent {
                Text(task.assignee?.name ?? "")
            } label: {
                Label {
                    Text(task.title).lineLimit(1)
                } icon: {
                    Circle().fill(task.project?.color.tint ?? .gray).frame(width: 8, height: 8)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
