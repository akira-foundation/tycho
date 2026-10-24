import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct DependencyPicker: View {
    let task: TaskItem
    let showsTitles: Bool
    let emptyText: String
    @State private var picking = false

    var body: some View {
        Button {
            picking = true
        } label: {
            label.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $picking) { DependencyList(task: task) }
        .accessibilityIdentifier("deps.\(task.key)")
    }

    @ViewBuilder private var label: some View {
        let blockers = task.orderedBlockedBy
        if blockers.isEmpty {
            Text(emptyText).foregroundStyle(Token.text4.color)
        } else {
            HStack(spacing: Spacing.s1) {
                ForEach(blockers) { blocker in
                    Text(blocker.key)
                        .tychoFont(.xxs, design: .monospaced)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Token.surface3.color, in: RoundedRectangle(cornerRadius: Radius.xs))
                        .help(blocker.title)
                    if showsTitles {
                        Text(blocker.title).lineLimit(1)
                    }
                }
            }
        }
    }
}

struct DependencyList: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            TextField("Blocked by…", text: $query)
                .textFieldStyle(.roundedBorder)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(DependencyActions.candidates(for: task, matching: query)) { candidate in
                        Button {
                            toast.perform { try DependencyActions(context: context).toggle(candidate, for: task) }
                        } label: {
                            row(candidate)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 320)
        }
        .padding(Spacing.s3)
        .frame(width: 320)
        .tychoFont(.sm)
    }

    private func row(_ candidate: TaskItem) -> some View {
        HStack(spacing: Spacing.s2) {
            StatusIcon(glyph: candidate.status.glyph, color: candidate.status.tint, size: 13)
            Text(candidate.key).tychoFont(.xxs, design: .monospaced).foregroundStyle(Token.text4.color)
            Text(candidate.title).lineLimit(1)
            Spacer()
            if task.isBlocked(by: candidate) {
                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
            }
        }
        .frame(height: 28)
        .contentShape(Rectangle())
    }
}
