import SwiftData
import SwiftUI
import TychoCore

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
            Form {
                Section {
                    TextField("Title", text: $title, axis: .vertical)
                        .marksTextEditing()
                        .font(.title3.weight(.semibold))
                        .labelsHidden()
                        .onSubmit { commitTitle(task) }
                        .accessibilityIdentifier("inspector.title")
                    NotesEditor(task: task).id(task.id)
                }
                TaskPropertiesSection(task: task)
                SubtaskList(task: task)
                AttachmentsSection(task: task)
            }
            .formStyle(.grouped)
            .navigationTitle(task.key)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { actions(task) }
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
            ContentUnavailableView(
                "No Task Selected", systemImage: "sidebar.right", description: Text("Pick a task to see its details."))
        }
    }

    @ToolbarContentBuilder private func actions(_ task: TaskItem) -> some ToolbarContent {
        #if os(macOS)
        if presentedAsSheet {
            sheetActions(task)
        } else {
            windowActions(task)
        }
        #else
        windowActions(task)
        #endif
    }

    @ToolbarContentBuilder private func windowActions(_ task: TaskItem) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", role: .close) { router.closeInspector() }
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier("inspector.close")
        }
        ToolbarItem(placement: .primaryAction) {
            ControlGroup {
                favoriteButton(task)
                completeButton(task)
                moreMenu
            }
            .labelStyle(.iconOnly)
        }
    }

    #if os(macOS)
    @ToolbarContentBuilder private func sheetActions(_ task: TaskItem) -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            moreMenu.labelStyle(.iconOnly).menuIndicator(.hidden).fixedSize()
            favoriteButton(task)
            completeButton(task)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") { router.closeInspector() }
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier("inspector.close")
        }
    }
    #endif

    private func favoriteButton(_ task: TaskItem) -> some View {
        Button(
            task.isFavorite ? "Unfavorite" : "Favorite",
            systemImage: task.isFavorite ? "star.fill" : "star"
        ) {
            toast.perform { try TaskActions(context: context).toggleFavorite(task) }
        }
        .accessibilityIdentifier("inspector.favorite")
    }

    private func completeButton(_ task: TaskItem) -> some View {
        Button(
            task.status == .done ? "Reopen" : "Mark Complete",
            systemImage: task.status == .done ? "arrow.uturn.backward.circle" : "checkmark.circle"
        ) {
            toast.perform { try TaskActions(context: context).toggleDone(task) }
        }
        .accessibilityIdentifier("inspector.complete")
    }

    private var moreMenu: some View {
        Menu("More", systemImage: "ellipsis.circle") {
            Button("Delete Task", systemImage: "trash", role: .destructive) { confirmingDelete = true }
                .accessibilityIdentifier("inspector.delete")
        }
        .accessibilityIdentifier("inspector.more")
    }

    private func syncTitle(_ task: TaskItem) {
        title = task.title
        syncedTitle = task.title
    }

    private func commitTitle(_ task: TaskItem) {
        guard title != syncedTitle, toast.isStored(task, in: context), title != task.title else { return }
        toast.perform { try TaskActions(context: context).rename(task, to: title) }
        syncTitle(task)
    }
}
