import Foundation

enum WindowFrames {
    static let backupKey = "tycho.realWindowFrames"
    private static let prefixes = ["NSWindow Frame ", "NSSplitView Subview Frames "]

    static func saved(in defaults: UserDefaults) -> [String: Any] {
        defaults.dictionaryRepresentation().filter { key, _ in prefixes.contains { key.hasPrefix($0) } }
    }

    static func preserve(from real: UserDefaults, into testing: UserDefaults) {
        guard testing.object(forKey: backupKey) == nil else { return }
        testing.set(saved(in: real), forKey: backupKey)
    }

    static func restore(into real: UserDefaults, from testing: UserDefaults) {
        guard let backup = testing.dictionary(forKey: backupKey) else { return }
        for key in saved(in: real).keys where backup[key] == nil {
            real.removeObject(forKey: key)
        }
        for (key, value) in backup {
            real.set(value, forKey: key)
        }
        testing.removeObject(forKey: backupKey)
    }
}
