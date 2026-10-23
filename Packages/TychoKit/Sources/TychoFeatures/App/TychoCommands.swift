import SwiftUI
import TychoDesign

public struct TychoCommands: Commands {
    @FocusedValue(\.router) private var router
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system

    public init() {}

    public var body: some Commands {
        SidebarCommands()
        CommandGroup(replacing: .newItem) {
            Button("New Task") { router?.newTask() }
                .keyboardShortcut("n")
                .disabled(router == nil)
            Button("New Project") { router?.newProject() }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(router == nil)
        }
        CommandGroup(after: .sidebar) {
            Button("Toggle Dark Mode") { theme = theme == .dark ? .light : .dark }
                .keyboardShortcut("l", modifiers: [.command, .shift])
        }
    }
}
