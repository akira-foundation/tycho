import Foundation
import Synchronization
import Testing

struct ScratchDefaults {
    private static let checkout = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
    private static let issued = Mutex(0)

    let suite: String
    let defaults: UserDefaults

    init(name: String) throws {
        suite = "io.akira.tycho.tests.\(Self.checkout).\(name)"
        defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
    }

    static func numbered(_ prefix: String) throws -> ScratchDefaults {
        let number = issued.withLock { count in
            count += 1
            return count
        }
        return try ScratchDefaults(name: "\(prefix).\(number)")
    }

    func remove() {
        defaults.removePersistentDomain(forName: suite)
    }
}
