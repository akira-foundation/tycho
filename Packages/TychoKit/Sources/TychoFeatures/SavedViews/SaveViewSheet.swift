import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SaveViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @FocusState private var isNameFocused: Bool
    @State private var name = ""
    @State private var layout: SavedViewLayout = .list
    let project: Project

    static func filterSummary(count: Int) -> String {
        guard count > 0 else {
            return "No filters are active. The view will show all tasks. You can add filters after saving."
        }
        return "\(count) filter\(count == 1 ? "" : "s") will be saved with this view."
    }

    private var flow: SavedViewFlow { SavedViewFlow(context: context, router: router, toast: toast) }

    var body: some View {
        let count = flow.baseFilters(of: project).count
        NavigationStack {
            Form {
                Section {
                    TextField("View name", text: $name, prompt: Text("e.g. Design review queue"))
                        .marksTextEditing()
                        .focused($isNameFocused)
                        .onSubmit(save)
                        .accessibilityIdentifier("saveView.name")
                    Picker("Layout", selection: $layout) {
                        ForEach(SavedViewLayout.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                } footer: {
                    Label(
                        Self.filterSummary(count: count),
                        systemImage: count > 0 ? "line.3.horizontal.decrease" : "info.circle"
                    )
                    .tychoFont(.sm)
                    .foregroundStyle(Token.text3.color)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Save view")
            .navigationSubtitle("Save the current filters as a tab on this project.")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.buttonStyle(.tycho(.secondary))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save view", action: save)
                        .buttonStyle(.tycho(.primary))
                        .keyboardShortcut(.return, modifiers: .command)
                        .accessibilityIdentifier("saveView.save")
                }
            }
        }
        .frame(minWidth: 380, minHeight: 260)
        .onAppear { isNameFocused = true }
    }

    private func save() {
        flow.save(name: name, layout: layout, in: project)
        dismiss()
    }
}
