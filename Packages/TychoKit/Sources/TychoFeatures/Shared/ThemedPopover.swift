import SwiftUI
import TychoDesign

struct ThemedPopoverContent<Content: View>: View {
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system
    let content: Content

    var body: some View {
        content.preferredColorScheme(theme.colorScheme)
    }
}

extension View {
    func themedPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            ThemedPopoverContent(content: content())
        }
    }
}
