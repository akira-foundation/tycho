import Foundation

struct ScratchDefaults {
    let suite: String
    let defaults: UserDefaults

    init(name: String) {
        suite = "io.akira.tycho.tests.\(name)"
        defaults = UserDefaults(suiteName: suite) ?? .standard
    }

    func remove() {
        defaults.removePersistentDomain(forName: suite)
    }
}
