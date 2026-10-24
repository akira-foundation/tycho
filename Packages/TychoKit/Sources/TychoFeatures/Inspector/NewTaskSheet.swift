import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NewTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    @Query(sort: \Member.name) private var members: [Member]
    @State private var draft: TaskDraft
    @State private var project: Project?
    @State private var error: ValidationError?

    init(status: TaskStatus, due: Date? = nil) {
        var draft = TaskDraft(title: "", status: status)
        draft.due = due
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $draft.title)
                    .accessibilityIdentifier("task.title")
                    .onChange(of: draft.title) { error = nil }
                Picker("Project", selection: $project) {
                    ForEach(projects.filter { !$0.isArchived }) { Text($0.name).tag(Project?.some($0)) }
                }
                Picker("Status", selection: $draft.status) {
                    ForEach(TaskStatus.allCases) { Text($0.title).tag($0) }
                }
                Picker("Priority", selection: $draft.priority) {
                    ForEach(TaskPriority.allCases) { Text($0.title).tag($0) }
                }
                Picker("Assignee", selection: $draft.assignee) {
                    Text("Unassigned").tag(Member?.none)
                    ForEach(members) { Text($0.name).tag(Member?.some($0)) }
                }
                LabeledContent("Due") {
                    DatePill(date: draft.due, emptyText: "No date") { draft.due = $0 }
                }
                if let error {
                    Text(error.userMessage).foregroundStyle(Token.red.color)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: save)
                        .keyboardShortcut(.return, modifiers: .command)
                        .disabled(project == nil)
                        .accessibilityIdentifier("task.create")
                }
            }
            .overlay {
                if projects.isEmpty {
                    EmptyState(
                        title: "No projects yet", symbol: "folder", message: "Create a project before adding tasks.")
                }
            }
        }
        .frame(minWidth: 420, minHeight: 360)
        .onAppear {
            project = NewTaskTarget.project(current: router.currentProjectID, projects: projects)
            draft.assignee = members.first(where: \.isMe)
        }
    }

    private func save() {
        guard let project else { return }
        do {
            try TaskActions(context: context).create(draft, in: project)
            dismiss()
        } catch let validation as ValidationError {
            error = validation
        } catch {
            toast.report(error)
        }
    }
}
