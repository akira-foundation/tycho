import SwiftUI
import TychoDesign

struct ShortcutsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 22, alignment: .top)], spacing: 22) {
                    ForEach(Array(ShortcutCatalog.groups.enumerated()), id: \.offset) { _, group in
                        ShortcutGroupView(title: group.title, entries: group.entries)
                    }
                }
                .padding(20)
            }
            .accessibilityIdentifier("shortcuts.sheet")
            .navigationTitle("Keyboard shortcuts")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 620, minHeight: 420)
        #endif
    }
}
