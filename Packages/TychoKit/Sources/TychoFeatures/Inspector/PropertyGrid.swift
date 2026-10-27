import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct PropertyGrid: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Member.name) private var members: [Member]
    let task: TaskItem
    @Environment(Router.self) private var router
    @State private var estimate = ""
    @State private var syncedEstimate = ""
    @State private var flushToken = UUID()

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: Spacing.s4, verticalSpacing: Spacing.s2) {
            row("Status") {
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
            }
            row("Priority") {
                Picker(
                    "Priority",
                    selection: Binding(
                        get: { task.priority },
                        set: { priority in
                            edit { $0.priority = priority }
                        })
                ) {
                    ForEach(TaskPriority.allCases) { Text($0.title).tag($0) }
                }
            }
            row("Assignee") {
                Picker(
                    "Assignee",
                    selection: Binding(
                        get: { task.assignee },
                        set: { member in
                            edit { $0.assignee = member }
                        })
                ) {
                    Text("Unassigned").tag(Member?.none)
                    ForEach(members) { Text($0.name).tag(Member?.some($0)) }
                }
            }
            row("Start") { dateField(\.start) }
            row("Due") { dateField(\.due) }
            row("Labels") { labelsMenu }
            row("Blocked by") { DependencyPicker(task: task, showsTitles: true, emptyText: "None") }
            row("Estimate") {
                TextField("e.g. 2d", text: $estimate)
                    .textFieldStyle(.plain)
                    .onSubmit(commitEstimate)
            }
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
        .labelsHidden()
        .tychoFont(.base)
    }

    private var labelsMenu: some View {
        Menu {
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
        } label: {
            let labels = TaskLabel.allCases.filter(task.labels.contains)
            if labels.isEmpty {
                Text("Add labels").foregroundStyle(Token.text4.color)
            } else {
                FlowRow(labels: labels)
            }
        }
        .menuStyle(.borderlessButton)
    }

    private func row<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        GridRow {
            Text(title).foregroundStyle(Token.text3.color).gridColumnAlignment(.leading)
            content()
        }
        .frame(minHeight: 30)
    }

    private func dateField(_ keyPath: ReferenceWritableKeyPath<TaskItem, Date?>) -> some View {
        DatePill(date: task[keyPath: keyPath], emptyText: "Set date") { value in
            edit { $0[keyPath: keyPath] = value }
        }
    }

    private func syncEstimate() {
        estimate = task.estimate ?? ""
        syncedEstimate = estimate
    }

    private func commitEstimate() {
        guard estimate != syncedEstimate, TaskActions(context: context).isStored(task) else { return }
        let value = Estimate.normalized(estimate)
        guard value != task.estimate else { return }
        edit { $0.estimate = value }
        syncEstimate()
    }

    private func edit(_ change: (TaskItem) -> Void) {
        toast.perform { try TaskActions(context: context).edit(task, change) }
    }
}
