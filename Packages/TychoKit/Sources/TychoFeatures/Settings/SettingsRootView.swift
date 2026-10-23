import SwiftUI

public struct SettingsRootView: View {
    private let loader: StoreLoader
    @State private var router = Router()
    @State private var toast = ToastCenter()

    public init(loader: StoreLoader) {
        self.loader = loader
    }

    public var body: some View {
        Group {
            switch loader.state {
            case .ready(let container):
                SettingsView().modelContainer(container)
            case .loading, .failed:
                Text("Data is unavailable.").padding()
            }
        }
        .environment(router)
        .environment(toast)
        .frame(width: 460)
        .tychoAppearance()
    }
}
