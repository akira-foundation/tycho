import SwiftUI

private struct LocalSheetTracking: ViewModifier {
    @Environment(Router.self) private var router
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, initial: true) { _, presented in router.isShowingLocalSheet = presented }
            .onDisappear {
                if isPresented { router.isShowingLocalSheet = false }
            }
    }
}

extension View {
    func blocksNavigation(while isPresented: Bool) -> some View {
        modifier(LocalSheetTracking(isPresented: isPresented))
    }
}
