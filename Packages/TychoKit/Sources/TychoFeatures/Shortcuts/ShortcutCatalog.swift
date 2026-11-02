public enum ShortcutCatalog {
    public typealias Entry = (label: String, keys: [String])
    public typealias Group = (title: String, entries: [Entry])

    public static let groups: [Group] = [
        (
            "General",
            [
                ("Command menu", ["⌘", "K"]),
                ("Search", ["/"]),
                ("Keyboard shortcuts", ["?"]),
                ("Toggle sidebar", ["["]),
                ("Toggle dark mode", ["⌘", "⇧", "L"]),
                ("Close panel or dialog", ["Esc"]),
            ]
        ),
        (
            "Create",
            [
                ("New task", ["N"]),
                ("New project", ["P"]),
                ("Submit form", ["⌘", "↵"]),
            ]
        ),
        (
            "Navigate",
            [
                ("Go to Home", ["G", "H"]),
                ("Go to My Tasks", ["G", "T"]),
                ("Go to Projects", ["G", "P"]),
                ("Go to Calendar", ["G", "C"]),
                ("Go to Settings", ["G", "S"]),
            ]
        ),
        (
            "Command menu",
            [
                ("Move selection", ["↑", "↓"]),
                ("Run command", ["↵"]),
                ("Search mode", ["Tab"]),
            ]
        ),
    ]
}
