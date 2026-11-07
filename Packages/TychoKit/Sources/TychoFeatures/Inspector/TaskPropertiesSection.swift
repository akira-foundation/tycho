import SwiftData
import SwiftUI
import TychoCore

struct TaskPropertiesSection: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Member.name) private var members: [Member]
    let task: TaskItem
    @Environment(Router.self) private var router
    @State private var estimate = ""
    @State private var syncedEstimate = ""
    @State private var flushToken = UUID()

    var body: some View {
        Section {
            Picker(
                "Status",
                selection: Binding(
                    get: { task.status },
                    set: { status in
                        toast.perform { try TaskActions(context: context).setStatus(task, status) }
                    })
            ) {
                ForEach(TaskStatus.allCases) { Text($0.title).tag($0) }
            }
            Picker(
                "Priority", selection: Binding(get: { task.priority }, set: { value in edit { $0.priority = value } })
            ) {
                ForEach(TaskPriority.allCases) { Text($0.title).tag($0) }
            }
            Picker(
                "Assignee", selection: Binding(get: { task.assignee }, set: { value in edit { $0.assignee = value } })
            ) {
                Text("Unassigned").tag(Member?.none)
                ForEach(members) { Text($0.name).tag(Member?.some($0)) }
            }
        }
        Section {
            OptionalDateRow(title: "Start", date: task.start) { value in edit { $0.start = value } }
            OptionalDateRow(title: "Due", date: task.due) { value in edit { $0.due = value } }
            LabeledContent("Estimate") {
                TextField("Estimate", text: $estimate, prompt: Text("e.g. 2d"))
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
                    .marksTextEditing()
                    .onSubmit(commitEstimate)
            }
        }
        Section {
            LabeledContent("Labels") { labelsMenu }
            LabeledContent("Blocked By") { DependencyPicker(task: task, showsTitles: false, emptyText: "None") }
        }
        .onAppear {
            syncEstimate()
            router.registerInspectorFlush(flushToken, commitEstimate)
        }
        .onChange(of: task.id) { syncEstimate() }
        .onChange(of: task.estimate) { syncEstimate() }
        .onDisappear {
            commitEstimate()
            router.unregisterInspectorFlush(flushToken)
        }
    }

    static func labelSummary(_ labels: Set<TaskLabel>) -> String {
        let titles = TaskLabel.allCases.filter(labels.contains).map(\.title)
        return titles.isEmpty ? "None" : titles.formatted(.list(type: .and, width: .narrow))
    }

    private var labelsMenu: some View {
        Menu(Self.labelSummary(task.labels)) {
            ForEach(TaskLabel.allCases) { label in
                Toggle(
                    label.title,
                    isOn: Binding(
                        get: { task.labels.contains(label) },
                        set: { on in
                            edit { task in
                                if on { task.labels.insert(label) } else { task.labels.remove(label) }
                            }
                        }))
            }
        }
        .fixedSize()
    }

    private func syncEstimate() {
        estimate = task.estimate ?? ""
        syncedEstimate = estimate
    }

    private func commitEstimate() {
        guard estimate != syncedEstimate, toast.isStored(task, in: context) else { return }
        let value = Estimate.normalized(estimate)
        guard value != task.estimate else { return }
        edit { $0.estimate = value }
        syncEstimate()
    }

    private func edit(_ change: (TaskItem) -> Void) {
        toast.perform { try TaskActions(context: context).edit(task, change) }
    }
}
