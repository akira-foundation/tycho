import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskInspectorView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Query private var matches: [TaskItem]
    @State private var title = ""
    @State private var syncedTitle = ""
    @State private var flushToken = UUID()
    @State private var confirmingDelete = false

    let presentedAsSheet: Bool

    init(taskID: UUID, presentedAsSheet: Bool = false) {
        self.presentedAsSheet = presentedAsSheet
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
            .toastOverlay(toast, enabled: presentedAsSheet)
            .onAppear {
                syncTitle(task)
                router.registerInspectorFlush(flushToken) { commitTitle(task) }
            }
            .onChange(of: task.id) { syncTitle(task) }
            .onChange(of: task.title) { syncTitle(task) }
            .onDisappear {
                commitTitle(task)
                router.unregisterInspectorFlush(flushToken)
            }
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
            .accessibilityIdentifier("inspector.favorite")
            Button(
                task.status == .done ? "Reopen" : "Mark complete",
                systemImage: task.status == .done ? "arrow.uturn.backward.circle" : "checkmark.circle"
            ) {
                toast.perform { try TaskActions(context: context).toggleDone(task) }
            }
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("inspector.complete")
            Button("Delete", systemImage: "trash", role: .destructive) { confirmingDelete = true }
                .labelStyle(.iconOnly)
            Button("Close", systemImage: "xmark") { router.closeInspector() }
                .labelStyle(.iconOnly)
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier("inspector.close")
        }
        .buttonStyle(.borderless)
    }

    private func syncTitle(_ task: TaskItem) {
        title = task.title
        syncedTitle = task.title
    }

    private func commitTitle(_ task: TaskItem) {
        guard title != syncedTitle, TaskActions(context: context).isStored(task), title != task.title else { return }
        toast.perform { try TaskActions(context: context).rename(task, to: title) }
        syncTitle(task)
    }
}
