import Foundation

public enum PaletteAction: Equatable {
    case newTask
    case newProject
    case searchMode
    case go(AppRoute)
    case settings
    case appearanceSettings
    case toggleTheme
    case toggleSidebar
    case shortcuts
    case openTask(UUID)
    case openProject(UUID)
    case openFile(UUID)
    case fillQuery(String)
    case viewAll(String)
    case tasksPreset(TasksPreset)
}

public struct PaletteCommand: Identifiable {
    public let id: String
    public let title: String
    public let symbol: String
    public let hint: String?
    public let action: PaletteAction

    public init(id: String, title: String, symbol: String, hint: String? = nil, action: PaletteAction) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.hint = hint
        self.action = action
    }
}

public enum PaletteCommands {
    public static let themeID = "c-theme"

    public static func all(isDark: Bool) -> [PaletteCommand] {
        [
            PaletteCommand(id: "c-task", title: "Create task", symbol: "plus", hint: "N", action: .newTask),
            PaletteCommand(
                id: "c-proj", title: "Create project", symbol: "folder.badge.plus", hint: "P", action: .newProject),
            PaletteCommand(
                id: "c-search", title: "Search workspace", symbol: "magnifyingglass", hint: "/", action: .searchMode),
            PaletteCommand(id: "c-home", title: "Go to Home", symbol: "house", hint: "G H", action: .go(.home)),
            PaletteCommand(
                id: "c-my", title: "Go to My Tasks", symbol: "checklist", hint: "G T", action: .go(.myTasks)),
            PaletteCommand(id: "c-tasks", title: "Go to Tasks", symbol: "list.bullet.rectangle", action: .go(.tasks)),
            PaletteCommand(
                id: "c-projs", title: "Go to Projects", symbol: "folder", hint: "G P", action: .go(.projects)),
            PaletteCommand(
                id: "c-cal", title: "Go to Calendar", symbol: "calendar", hint: "G C", action: .go(.calendar)),
            PaletteCommand(id: "c-tl", title: "Go to Timeline", symbol: "chart.bar.xaxis", action: .go(.timeline)),
            PaletteCommand(id: "c-set", title: "Open settings", symbol: "gearshape", hint: "G S", action: .settings),
            PaletteCommand(
                id: "c-app", title: "Appearance settings", symbol: "paintpalette", action: .appearanceSettings),
            PaletteCommand(
                id: themeID,
                title: isDark ? "Switch to light mode" : "Switch to dark mode",
                symbol: isDark ? "sun.max" : "moon",
                hint: "⌘ ⇧ L",
                action: .toggleTheme),
            PaletteCommand(
                id: "c-side", title: "Toggle sidebar", symbol: "sidebar.left", hint: "[", action: .toggleSidebar),
            PaletteCommand(
                id: "c-keys", title: "Keyboard shortcuts", symbol: "keyboard", hint: "?", action: .shortcuts),
        ]
    }
}
