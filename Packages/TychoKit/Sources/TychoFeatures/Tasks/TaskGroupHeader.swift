import SwiftUI
import TychoCore
import TychoDesign

struct TaskGroupHeader: View {
    let group: TaskViewGroup
    let status: TaskStatus?
    let onAdd: (() -> Void)?
    @State private var isHovering = false
    @FocusState private var isAddFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.s2) {
            HStack(spacing: Spacing.s2) {
                if let status {
                    StatusIcon(glyph: status.glyph, color: status.tint)
                }
                Text(group.title)
                Text("\(group.tasks.count)").foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("group.\(group.id)")
            Spacer(minLength: 0)
            if let onAdd {
                Button("Add Task to \(group.title)", systemImage: "plus", action: onAdd)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .help("Add Task")
                    .focused($isAddFocused)
                    .opacity(revealsAdd ? 1 : 0)
                    .accessibilityHidden(isHoverOnly)
            }
        }
        .contentShape(Rectangle())
        .accessibilityActions {
            if let onAdd {
                Button("Add Task to \(group.title)", action: onAdd)
            }
        }
        .onHover { isHovering = $0 }
    }

    private var isHoverOnly: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    private var revealsAdd: Bool {
        !isHoverOnly || isHovering || isAddFocused
    }
}
