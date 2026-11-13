import SwiftData
import SwiftUI
import TychoCore

struct PendingAttachment: Identifiable {
    let id = UUID()
    let urls: [URL]
}

struct AttachFilesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    let urls: [URL]
    @State private var project: Project?
    @State private var task: TaskItem?

    init(urls: [URL], project: Project) {
        self.urls = urls
        _project = State(initialValue: project)
    }

    static func candidates(in project: Project?) -> [TaskItem] {
        (project?.tasks ?? []).sorted { $0.number < $1.number }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(urls, id: \.self) { url in
                        Label(url.lastPathComponent, systemImage: "doc")
                    }
                }
                Section {
                    Picker("Project", selection: $project) {
                        ForEach(projects.filter { !$0.isArchived }) { Text($0.name).tag(Project?.some($0)) }
                    }
                    .accessibilityIdentifier("attach.project")
                    Picker("Task", selection: $task) {
                        Text("Choose a Task").tag(TaskItem?.none)
                        ForEach(Self.candidates(in: project)) { candidate in
                            Text("\(candidate.key) \(candidate.title)").tag(TaskItem?.some(candidate))
                        }
                    }
                    .accessibilityIdentifier("attach.task")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Attach Files")
            .onChange(of: project) { task = nil }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Attach", action: attach)
                        .keyboardShortcut(.defaultAction)
                        .disabled(task == nil)
                        .accessibilityIdentifier("attach.confirm")
                }
            }
        }
        .frame(minWidth: 420, minHeight: 320)
    }

    private func attach() {
        guard let task else { return }
        FileUpload.perform(urls, project: task.project, task: task, context: context, toast: toast)
        dismiss()
    }
}
