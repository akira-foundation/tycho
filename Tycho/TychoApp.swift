import SwiftUI
import TychoFeatures

@main
struct TychoApp: App {
    @State private var loader = StoreLoader.live()

    var body: some Scene {
        WindowGroup {
            AppRootView(loader: loader)
        }
        .commands { TychoCommands() }
        #if os(macOS)
        Settings {
            SettingsRootView(loader: loader)
        }
        #endif
    }
}
