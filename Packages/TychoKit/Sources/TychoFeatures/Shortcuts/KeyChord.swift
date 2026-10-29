import Foundation

public enum ShortcutAction: Equatable {
    case palette
    case search
    case newTask
    case newProject
    case shortcuts
    case toggleSidebar
    case go(AppRoute)
    case settings
}

struct KeyChord {
    static let sequenceWindow: TimeInterval = 1.2

    private var armedAt: Date?

    func isArmed(at time: Date) -> Bool {
        guard let armedAt else { return false }
        return time.timeIntervalSince(armedAt) < Self.sequenceWindow
    }

    mutating func handle(_ key: Character, at time: Date, isEditingText: Bool, hasSheet: Bool) -> ShortcutAction? {
        let wasArmed = isArmed(at: time)
        armedAt = nil
        guard !isEditingText, !hasSheet else { return nil }
        let key = Character(key.lowercased())
        guard !wasArmed else { return Self.sequence(key) }
        guard key != "g" else {
            armedAt = time
            return nil
        }
        return Self.single(key)
    }

    private static func single(_ key: Character) -> ShortcutAction? {
        switch key {
        case "/": .search
        case "n": .newTask
        case "p": .newProject
        case "?": .shortcuts
        case "[": .toggleSidebar
        default: nil
        }
    }

    private static func sequence(_ key: Character) -> ShortcutAction? {
        switch key {
        case "h": .go(.home)
        case "t": .go(.myTasks)
        case "p": .go(.projects)
        case "c": .go(.calendar)
        case "s": .settings
        default: nil
        }
    }
}
