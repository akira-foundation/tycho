import SwiftUI
import TychoDesign

private struct ToastOverlay: ViewModifier {
    let toast: ToastCenter

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let message = toast.message {
                Text(message)
                    .tychoFont(.sm, weight: .medium)
                    .padding(.horizontal, Spacing.s4)
                    .padding(.vertical, Spacing.s2)
                    .background(Token.surface.color, in: Capsule())
                    .shadowPop(radius: Radius.full)
                    .padding(.bottom, Spacing.s6)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityIdentifier("toast")
            }
        }
    }
}

extension View {
    func toastOverlay(_ toast: ToastCenter) -> some View {
        modifier(ToastOverlay(toast: toast))
    }
}
