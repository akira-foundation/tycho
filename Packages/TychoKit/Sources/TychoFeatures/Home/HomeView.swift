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
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s6) {
                header
                stats(summary)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: Spacing.s4) {
                        myTasks(summary).frame(minWidth: 420)
                        VStack(spacing: Spacing.s4) {
                            projectProgress
                            deadlines(summary)
                        }
                        .frame(width: 320)
                    }
                    VStack(spacing: Spacing.s4) {
                        myTasks(summary)
                        projectProgress
                        deadlines(summary)
                    }
                }
            }
            .padding(Spacing.s6)
        }
        .background(Token.bg.color)
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem { Button("New Project", systemImage: "folder.badge.plus") { router.newProject() } }
            ToolbarItem { Button("New Task", systemImage: "plus") { router.newTask() } }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            let name = workspaces.first?.me?.firstName ?? ""
            Text("\(Greeting.text(hour: Calendar.current.component(.hour, from: .now))), \(name)")
                .tychoFont(.xxl, weight: .semibold)
            Text(
                "\(dateText.weekdayMonthDay(.now)) · Here's what's happening across your workspace."
            )
            .tychoFont(.base)
            .foregroundStyle(Token.text3.color)
        }
    }

    private func stats(_ summary: HomeSummary) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: Spacing.s3)], spacing: Spacing.s3) {
            StatCard(
                title: "Active projects", symbol: "folder", value: "\(summary.activeProjects)",
                detail: "\(summary.projectsAtRisk) at risk", tone: nil
            ) {
                router.open(.projects)
            }
            StatCard(
                title: "Open tasks", symbol: "circle.dashed", value: "\(summary.openTasks)",
                detail: "\(summary.openAssignedToMe) assigned to you", tone: nil
            ) {
                router.open(.myTasks)
            }
            StatCard(
                title: "Completed", symbol: "checkmark.circle", value: "\(summary.completedThisWeek)",
                detail: "this week", tone: nil
            ) {
                router.open(.myTasks)
            }
            StatCard(
                title: "Overdue",
                symbol: "clock.badge.exclamationmark",
                value: "\(summary.overdue)",
                detail: summary.overdue > 0 ? "need attention" : "all on track",
                tone: summary.overdue > 0 ? Token.red.color : nil
            ) {
                router.open(.myTasks)
            }
        }
    }

    private func myTasks(_ summary: HomeSummary) -> some View {
        Panel(title: "My tasks") {
            Picker("Tasks", selection: $tab) {
                ForEach(HomeTab.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            let list = tab.tasks(in: summary)
            if list.isEmpty {
                Text("Nothing here").tychoFont(.sm).foregroundStyle(Token.text4.color).padding(.vertical, Spacing.s3)
            } else {
                ForEach(list) { TaskRow(task: $0, showsProject: true) }
            }
        }
    }

    private var projectProgress: some View {
        Panel(title: "Project progress") {
            ForEach(projects.filter { !$0.isArchived && $0.status != .complete }) { project in
                Button {
                    router.openProject(project.id, tab: .board)
                } label: {
                    HStack(spacing: Spacing.s2) {
                        ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 18)
                        Text(project.name).tychoFont(.base).lineLimit(1)
                        Spacer()
                        ProgressRing(percent: project.progress, color: project.color.tint)
                        Text("\(project.progress)%").tychoFont(.xs).monospacedDigit().foregroundStyle(Token.text3.color)
                    }
                    .frame(height: 30)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func deadlines(_ summary: HomeSummary) -> some View {
        Panel(title: "Upcoming deadlines") {
            ForEach(summary.deadlines) { bucket in
                VStack(alignment: .leading, spacing: Spacing.s1) {
                    HStack {
                        Text(bucket.title).tychoFont(.xs, weight: .semibold).foregroundStyle(Token.text2.color)
                        Text("\(bucket.tasks.count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
                    }
                    if bucket.tasks.isEmpty {
                        Text("Nothing due").tychoFont(.sm).foregroundStyle(Token.text4.color)
                    }
                    ForEach(bucket.tasks.prefix(4)) { task in
                        Button {
                            router.inspect(task.id)
                        } label: {
                            HStack(spacing: Spacing.s2) {
                                Circle().fill(task.project?.color.tint ?? Token.gray.color).frame(width: 6, height: 6)
                                Text(task.title).tychoFont(.base).lineLimit(1)
                                Spacer()
                                PriorityIcon(weight: task.priority.weight, size: 13)
                                if let assignee = task.assignee {
                                    Avatar(initials: assignee.initials, color: assignee.tint, size: 18)
                                }
                            }
                            .frame(height: 30)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    if bucket.tasks.count > 4 {
                        Text("+\(bucket.tasks.count - 4) more").tychoFont(.xs).foregroundStyle(Token.text4.color)
                    }
                }
            }
        }
    }
}

struct Panel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            Text(title).tychoFont(.md, weight: .semibold)
            content
        }
        .padding(Spacing.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .shadowCard(radius: Radius.lg)
    }
}
