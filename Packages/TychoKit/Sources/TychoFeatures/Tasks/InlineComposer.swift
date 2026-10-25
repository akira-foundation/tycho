import SwiftUI
import TychoDesign

struct InlineComposer: View {
    let placeholder: String
    let onSubmit: (String) -> Void
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: Spacing.s2) {
            Image(systemName: "plus").foregroundStyle(Token.text4.color)
            TextField(placeholder, text: $text)
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
        .tychoFont(.base)
        .frame(height: 32)
    }
}
