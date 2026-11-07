import SwiftUI

struct InlineComposer: View {
    let placeholder: String
    let onSubmit: (String) -> Void
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus").foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .marksTextEditing(isFocused: focused)
                .textFieldStyle(.plain)
                .focused($focused)
                .onSubmit {
                    let value = text
                    text = ""
                    focused = true
                    guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    onSubmit(value)
                }
                .onKeyPress(.escape) {
                    text = ""
                    focused = false
                    return .handled
                }
        }
        .frame(minHeight: 32)
    }
}
