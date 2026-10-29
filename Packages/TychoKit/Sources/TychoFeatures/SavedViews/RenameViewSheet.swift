import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct RenameViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @FocusState private var isNameFocused: Bool
    @State private var name: String
    let view: SavedView

    init(view: SavedView) {
        self.view = view
        _name = State(initialValue: view.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("View name", text: $name)
                    .marksTextEditing()
                    .focused($isNameFocused)
                    .onSubmit(save)
                    .accessibilityIdentifier("renameView.name")
            }
            .formStyle(.grouped)
            .navigationTitle("Rename view")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.buttonStyle(.tycho(.secondary))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .buttonStyle(.tycho(.primary))
                        .keyboardShortcut(.return, modifiers: .command)
                        .accessibilityIdentifier("renameView.save")
                }
            }
        }
        .frame(minWidth: 340, minHeight: 160)
        .onAppear { isNameFocused = true }
    }

    private func save() {
        SavedViewFlow(context: context, router: router, toast: toast).rename(view, to: name)
        dismiss()
    }
}
