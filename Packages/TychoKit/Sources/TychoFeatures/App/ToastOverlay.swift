import SwiftUI
import TychoDesign

private struct ToastOverlay: ViewModifier {
    let toast: ToastCenter
    let enabled: Bool

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if enabled, let message = toast.message {
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
        .tychoAnimation(value: toast.message)
    }
}

extension View {
    func toastOverlay(_ toast: ToastCenter, enabled: Bool = true) -> some View {
        modifier(ToastOverlay(toast: toast, enabled: enabled))
    }
}
