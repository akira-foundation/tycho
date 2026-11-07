import SwiftUI

extension View {
    func themedPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            content().modifier(ThemeSchemeModifier())
        }
    }
}
