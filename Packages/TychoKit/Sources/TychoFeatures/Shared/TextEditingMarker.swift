import SwiftUI

struct TextEditingObserver: ViewModifier {
    let isFocused: Bool
    @Environment(Router.self) private var router: Router?
    @State private var field = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear { router?.markEditing(field, isFocused) }
            .onChange(of: isFocused) { router?.markEditing(field, isFocused) }
            .onDisappear { router?.markEditing(field, false) }
    }
}

struct TextEditingMarker: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .modifier(TextEditingObserver(isFocused: isFocused))
    }
}

extension View {
    func marksTextEditing() -> some View {
        modifier(TextEditingMarker())
    }

    func marksTextEditing(isFocused: Bool) -> some View {
        modifier(TextEditingObserver(isFocused: isFocused))
    }
}
