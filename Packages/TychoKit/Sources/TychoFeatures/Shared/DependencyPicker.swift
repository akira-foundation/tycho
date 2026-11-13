import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct DependencyPicker: View {
    let task: TaskItem
    let emptyText: String
    @State private var picking = false

    var body: some View {
        Button {
            picking = true
        } label: {
            label.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .themedPopover(isPresented: $picking) { DependencyList(task: task) }
        .accessibilityIdentifier("deps.\(task.key)")
    }

    static func summary(of blockers: [TaskItem]) -> String {
        blockers.map(\.key).joined(separator: ", ")
    }

    @ViewBuilder private var label: some View {
        let blockers = task.orderedBlockedBy
        if blockers.isEmpty {
            Text(emptyText).foregroundStyle(.tertiary)
        } else {
            Text(Self.summary(of: blockers))
                .font(.body.monospaced())
                .foregroundStyle(.secondary)
                .help(blockers.map(\.title).joined(separator: ", "))
        }
    }
}

struct DependencyList: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search", text: $query)
                .marksTextEditing()
            List(DependencyActions.candidates(for: task, matching: query)) { candidate in
                Toggle(isOn: binding(for: candidate)) {
                    HStack(spacing: 8) {
                        StatusIcon(glyph: candidate.status.glyph, color: candidate.status.tint, size: 13)
                        Text(candidate.key).font(.body.monospaced()).foregroundStyle(.secondary)
                        Text(candidate.title).lineLimit(1)
                    }
                }
                .checkboxToggleStyle()
            }
            .frame(minHeight: 160, idealHeight: 280, maxHeight: 280)
        }
        .padding()
        .frame(width: 320)
    }

    private func binding(for candidate: TaskItem) -> Binding<Bool> {
        Binding(
            get: { task.isBlocked(by: candidate) },
            set: { requested in
                guard requested != task.isBlocked(by: candidate) else { return }
                toast.perform { try DependencyActions(context: context).toggle(candidate, for: task) }
            }
        )
    }
}

extension View {
    @ViewBuilder fileprivate func checkboxToggleStyle() -> some View {
        #if os(macOS)
        self.toggleStyle(.checkbox)
        #else
        self
        #endif
    }
}
