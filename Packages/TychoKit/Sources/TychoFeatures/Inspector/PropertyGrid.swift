import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct PropertyGrid: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Member.name) private var members: [Member]
    let task: TaskItem
    @State private var estimate = ""

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
            row("Start") { dateField("Start", \.start) }
            row("Due") { dateField("Due", \.due) }
            row("Labels") { labelsMenu }
            row("Estimate") {
                TextField("e.g. 2d", text: $estimate)
                    .textFieldStyle(.plain)
                    .onSubmit(commitEstimate)
            }
        }
        .onAppear { estimate = task.estimate ?? "" }
        .onChange(of: task.id) { estimate = task.estimate ?? "" }
        .onDisappear(perform: commitEstimate)
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

    private func dateField(_ title: String, _ keyPath: ReferenceWritableKeyPath<TaskItem, Date?>) -> some View {
        HStack {
            if let date = task[keyPath: keyPath] {
                DatePicker(
                    title,
                    selection: Binding(get: { date }, set: { value in edit { $0[keyPath: keyPath] = value } }),
                    displayedComponents: .date)
                Button("Clear", systemImage: "xmark.circle.fill") { edit { $0[keyPath: keyPath] = nil } }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(Token.text4.color)
            } else {
                Button("Set date") {
                    edit { $0[keyPath: keyPath] = Calendar.current.startOfDay(for: .now).addingTimeInterval(12 * 3600) }
                }
                .buttonStyle(.plain)
                .foregroundStyle(Token.text4.color)
            }
        }
    }

    private func commitEstimate() {
        guard !task.isDeleted, task.modelContext != nil else { return }
        let trimmed = estimate.trimmingCharacters(in: .whitespaces)
        let value = trimmed.isEmpty ? nil : trimmed
        guard value != task.estimate else { return }
        edit { $0.estimate = value }
    }

    private func edit(_ change: (TaskItem) -> Void) {
        toast.perform { try TaskActions(context: context).edit(task, change) }
    }
}
