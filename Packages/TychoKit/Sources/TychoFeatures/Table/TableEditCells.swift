import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

enum EstimateOptions {
    static let quick = ["30m", "1h", "2h", "4h", "1d", "2d", "3d", "5d", "8d"]

    static func normalized(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct DateCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(\.dateText) private var dateText
    let task: TaskItem
    let keyPath: ReferenceWritableKeyPath<TaskItem, Date?>
    let highlightsOverdue: Bool
    @State private var picking = false

    var body: some View {
        Button {
            picking = true
        } label: {
            Text(task[keyPath: keyPath].map(dateText.short) ?? "—")
                .monospacedDigit()
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $picking) {
            VStack(alignment: .leading, spacing: Spacing.s2) {
                DatePicker(
                    "Date",
                    selection: Binding(
                        get: { task[keyPath: keyPath] ?? .now },
                        set: { value in
                            edit { $0[keyPath: keyPath] = DayTime.noon(of: value, calendar: DateText.gregorian) }
                        }),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                Button("Clear date", role: .destructive) {
                    edit { $0[keyPath: keyPath] = nil }
                    picking = false
                }
            }
            .padding(Spacing.s3)
        }
    }

    private var color: Color {
        switch (task[keyPath: keyPath] == nil, highlightsOverdue && task.isOverdue(now: .now, calendar: .current)) {
        case (true, _): Token.text4.color
        case (false, true): Token.red.color
        case (false, false): Token.text.color
        }
    }

    private func edit(_ change: (TaskItem) -> Void) {
        toast.perform { try TaskActions(context: context).edit(task, change) }
    }
}

struct LabelsCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem

    var body: some View {
        Menu {
            ForEach(TaskLabel.allCases) { label in
                Toggle(
                    label.title,
                    isOn: Binding(
                        get: { task.labels.contains(label) },
                        set: { on in
                            toast.perform {
                                try TaskActions(context: context).edit(task) { task in
                                    if on { task.labels.insert(label) } else { task.labels.remove(label) }
                                }
                            }
                        }))
            }
        } label: {
            let labels = TaskLabel.allCases.filter(task.labels.contains)
            if labels.isEmpty {
                Text("—").foregroundStyle(Token.text4.color)
            } else {
                FlowRow(labels: labels)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
}

struct EstimateCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    @State private var editing = false
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: Spacing.s1) {
            if editing {
                TextField("e.g. 2d", text: $text)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .onAppear { focused = true }
                    .onSubmit(commit)
                    .onKeyPress(.escape) {
                        editing = false
                        return .handled
                    }
                    .onChange(of: focused) {
                        if !focused { commit() }
                    }
            } else {
                Text(task.estimate ?? "—")
                    .foregroundStyle(task.estimate == nil ? Token.text4.color : Token.text.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: beginEditing)
                    .help("Click to edit")
            }
            Menu {
                ForEach(EstimateOptions.quick, id: \.self) { option in
                    Button(option) { set(option) }
                }
                Divider()
                Button("Clear estimate") { set(nil) }
            } label: {
                Image(systemName: "timer")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .accessibilityLabel("Estimate options")
        }
        .monospacedDigit()
    }

    private func beginEditing() {
        text = task.estimate ?? ""
        editing = true
    }

    private func commit() {
        guard editing else { return }
        editing = false
        set(EstimateOptions.normalized(text))
    }

    private func set(_ value: String?) {
        guard value != task.estimate else { return }
        toast.perform { try TaskActions(context: context).edit(task) { $0.estimate = value } }
    }
}
