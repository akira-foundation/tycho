import SwiftData
import SwiftUI
import TychoCore

struct TaskMenu: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var confirmingDelete = false

    var body: some View {
        Button("Open") { router.inspect(task.id) }
        Menu("Status") {
            ForEach(TaskStatus.allCases) { status in
                Button(status.title) { toast.perform { try TaskActions(context: context).setStatus(task, status) } }
            }
        }
        Menu("Priority") {
            ForEach(TaskPriority.allCases) { priority in
                Button(priority.title) {
                    toast.perform { try TaskActions(context: context).edit(task) { $0.priority = priority } }
                }
            }
        }
        Button(task.status == .done ? "Reopen" : "Mark complete") {
            toast.perform { try TaskActions(context: context).toggleDone(task) }
        }
        Button(task.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
            toast.perform { try TaskActions(context: context).toggleFavorite(task) }
        }
        Divider()
        Button("Delete", role: .destructive) { confirmingDelete = true }
            .confirmationDialog("Delete \(task.key)?", isPresented: $confirmingDelete) {
                Button("Delete", role: .destructive, action: delete)
            }
    }

    private func delete() {
        let id = task.id
        toast.perform {
            try TaskActions(context: context).delete(task)
            if router.inspectedTaskID == id { router.closeInspector() }
        }
    }
}
