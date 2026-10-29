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
            Button("Toggle Dark Mode") { theme = .toggled(isDark: theme.resolvesDark) }
                .keyboardShortcut("l", modifiers: [.command, .shift])
        }
        CommandMenu("Go") {
            Button("Command Menu") { router?.perform(.palette) }
                .keyboardShortcut("k")
                .disabled(router == nil)
            item("Search", hint: "/", action: .search)
            Divider()
            item("Home", hint: "G then H", action: .go(.home))
            item("My Tasks", hint: "G then T", action: .go(.myTasks))
            item("Projects", hint: "G then P", action: .go(.projects))
            item("Calendar", hint: "G then C", action: .go(.calendar))
            item("Settings", hint: "G then S", action: .settings)
        }
        CommandGroup(after: .help) {
            item("Keyboard Shortcuts", hint: "?", action: .shortcuts)
        }
    }

    private func item(_ title: String, hint: String, action: ShortcutAction) -> some View {
        Button {
            router?.perform(action)
        } label: {
            Text(title)
            Text(hint)
        }
        .disabled(router == nil)
    }
}
