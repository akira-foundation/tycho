import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskInspectorView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    @Query private var matches: [TaskItem]
    @State private var title = ""
    @State private var confirmingDelete = false

    private var isSheet: Bool {
        #if os(iOS)
        sizeClass == .compact
        #else
        false
        #endif
    }

    init(taskID: UUID) {
        _matches = Query(filter: #Predicate<TaskItem> { $0.id == taskID })
    }

    var body: some View {
        if let task = matches.first {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s5) {
                    header(task)
                    TextField("Title", text: $title)
                        .tychoFont(.xl, weight: .semibold)
                        .textFieldStyle(.plain)
                        .onSubmit { commitTitle(task) }
                        .accessibilityIdentifier("inspector.title")
                    PropertyGrid(task: task)
                    Divider()
                    NotesEditor(task: task)
                    Divider()
                    SubtaskList(task: task)
                    Divider()
                    AttachmentsSection(task: task)
                }
                .padding(Spacing.s5)
            }
            .background(Token.surface.color)
            .toastOverlay(toast, enabled: isSheet)
            .onAppear { title = task.title }
            .onChange(of: task.id) { title = task.title }
            .onDisappear { commitTitle(task) }
            .confirmationDialog("Delete \(task.key)?", isPresented: $confirmingDelete) {
                Button("Delete task", role: .destructive) {
                    router.closeInspector()
                    toast.perform { try TaskActions(context: context).delete(task) }
                }
            }
        } else {
            EmptyState(title: "No task selected", symbol: "sidebar.right", message: "Pick a task to see its details.")
        }
    }

    private func header(_ task: TaskItem) -> some View {
        HStack {
            Text(task.key).tychoFont(.xs, design: .monospaced).foregroundStyle(Token.text4.color)
            Spacer()
            Button(
                task.isFavorite ? "Unfavorite" : "Favorite",
                systemImage: task.isFavorite ? "star.fill" : "star"
            ) {
                toast.perform { try TaskActions(context: context).toggleFavorite(task) }
            }
            .labelStyle(.iconOnly)
            Button(
                task.status == .done ? "Reopen" : "Mark complete",
                systemImage: task.status == .done ? "arrow.uturn.backward.circle" : "checkmark.circle"
            ) {
                toast.perform { try TaskActions(context: context).toggleDone(task) }
            }
            .labelStyle(.iconOnly)
            Button("Delete", systemImage: "trash", role: .destructive) { confirmingDelete = true }
                .labelStyle(.iconOnly)
            Button("Close", systemImage: "xmark") { router.closeInspector() }
                .labelStyle(.iconOnly)
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier("inspector.close")
        }
        .buttonStyle(.borderless)
    }

    private func commitTitle(_ task: TaskItem) {
        guard !task.isDeleted, task.modelContext != nil, title != task.title else { return }
        toast.perform { try TaskActions(context: context).rename(task, to: title) }
        title = task.title
    }
}
