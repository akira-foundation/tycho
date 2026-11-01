import Foundation
import Testing

struct ScratchDefaults {
    private static let checkout = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().lastPathComponent

    let suite: String
    let defaults: UserDefaults

    init(name: String) throws {
        suite = "io.akira.tycho.tests.\(Self.checkout).\(name)"
        defaults = try #require(UserDefaults(suiteName: suite))
    }

    func remove() {
        defaults.removePersistentDomain(forName: suite)
    }
}
