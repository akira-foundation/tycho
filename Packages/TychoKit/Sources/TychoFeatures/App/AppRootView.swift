import SwiftData
import SwiftUI
import TychoDesign

public struct AppRootView: View {
    private let loader: StoreLoader
    @State private var router = Router()
    @State private var toast = ToastCenter()

    public init(loader: StoreLoader) {
        self.loader = loader
    }

    public var body: some View {
        Group {
            switch loader.state {
            case .loading:
                ProgressView().task { loader.load() }
            case .ready(let container):
                RootView().modelContainer(container)
            case .failed(let message):
                RecoveryView(message: message, retry: loader.load, reset: loader.resetAndReload)
            }
        }
        .environment(router)
        .environment(toast)
        .focusedSceneValue(\.router, router)
        .overlay(alignment: .bottom) { toastView }
        .tychoAppearance()
    }

    @ViewBuilder private var toastView: some View {
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
