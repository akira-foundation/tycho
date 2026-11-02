import Foundation

public enum ShortcutAction: Equatable, Sendable {
    case palette
    case search
    case newTask
    case newProject
    case shortcuts
    case toggleSidebar
    case go(AppRoute)
    case settings
}

struct ShortcutKeyResult: Equatable, Sendable {
    static let passThrough = ShortcutKeyResult(action: nil, consumes: false)

    let action: ShortcutAction?
    let consumes: Bool
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

    mutating func receive(
        _ key: Character, hasOption: Bool, at time: Date, isEditingText: Bool, hasSheet: Bool
    ) -> ShortcutKeyResult {
        guard Self.isPrintable(key) else {
            armedAt = nil
            return .passThrough
        }
        guard !hasOption || key == "[" else { return .passThrough }
        let wasArmed = isArmed(at: time)
        let action = handle(key, at: time, isEditingText: isEditingText, hasSheet: hasSheet)
        guard !isEditingText, !hasSheet else { return .passThrough }
        return ShortcutKeyResult(action: action, consumes: action != nil || wasArmed || isArmed(at: time))
    }

    static func isPrintable(_ key: Character) -> Bool {
        key.unicodeScalars.allSatisfy { scalar in
            switch scalar.properties.generalCategory {
            case .control, .privateUse, .format, .surrogate, .unassigned: false
            default: true
            }
        }
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
