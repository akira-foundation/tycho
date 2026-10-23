import SwiftData
import SwiftUI

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
        .toastOverlay(toast)
        .tychoAppearance()
    }
}
