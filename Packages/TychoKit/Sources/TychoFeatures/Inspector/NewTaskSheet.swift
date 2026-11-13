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
    @State private var didCreate = false
    @FocusState private var isTitleFocused: Bool

    init(status: TaskStatus, due: Date? = nil) {
        var draft = TaskDraft(title: "", status: status)
        draft.due = due
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title, prompt: Text("Title"))
                        .labelsHidden()
                        .marksTextEditing(isFocused: isTitleFocused)
                        .focused($isTitleFocused)
                        .onSubmit(save)
                        .accessibilityIdentifier("task.title")
                        .onChange(of: draft.title) { error = nil }
                    TextField("Notes", text: $draft.notes, prompt: Text("Notes"), axis: .vertical)
                        .labelsHidden()
                        .lineLimit(3...6)
                        .marksTextEditing()
                        .accessibilityIdentifier("task.notes")
                } footer: {
                    if let error {
                        Text(error.userMessage).foregroundStyle(.red)
                    }
                }
                Section {
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
                }
                Section {
                    Toggle("Due", isOn: hasDue)
                        .accessibilityIdentifier("task.hasDue")
                    if let due = draft.due {
                        DatePicker(
                            "Due date",
                            selection: Binding(get: { due }, set: { draft.due = DatePill.normalized($0) }),
                            displayedComponents: .date
                        )
                        .accessibilityIdentifier("task.due")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", role: .confirm, action: save)
                        .keyboardShortcut(.defaultAction)
                        .disabled(project == nil)
                        .accessibilityIdentifier("task.create")
                }
            }
            .overlay {
                if projects.isEmpty {
                    EmptyState(
                        title: "No Projects", symbol: "folder", message: "Create a project before adding tasks.")
                }
            }
        }
        .frame(minWidth: 420, minHeight: 360)
        .onAppear {
            project = NewTaskTarget.project(current: router.currentProjectID, projects: projects)
            draft.assignee = members.first(where: \.isMe)
            isTitleFocused = true
        }
    }

    private var hasDue: Binding<Bool> {
        Binding(
            get: { draft.due != nil },
            set: { draft.setHasDue($0, today: .now, calendar: DateText.gregorian) })
    }

    private func save() {
        guard let project, !didCreate else { return }
        do {
            try TaskActions(context: context).create(draft, in: project)
            didCreate = true
            dismiss()
        } catch let validation as ValidationError {
            error = validation
        } catch {
            toast.report(error)
        }
    }
}
