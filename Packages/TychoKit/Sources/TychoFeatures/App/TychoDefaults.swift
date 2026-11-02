import Foundation

public enum TychoDefaults {
    public static let uiTestingSuite = "io.akira.tycho.uitesting"

    nonisolated(unsafe) public static let current = store(arguments: ProcessInfo.processInfo.arguments)

    static func isUITesting(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> Bool {
        arguments.contains("-uiTesting")
    }

    static func store(arguments: [String], suite: String = uiTestingSuite) -> UserDefaults {
        guard isUITesting(arguments), let testing = UserDefaults(suiteName: suite) else { return .standard }
        return testing
    }

    public static func prepareLaunch(
        arguments: [String] = ProcessInfo.processInfo.arguments, suite: String = uiTestingSuite,
        real: UserDefaults = .standard
    ) {
        guard let testing = UserDefaults(suiteName: suite) else { return }
        guard isUITesting(arguments) else {
            WindowFrames.restore(into: real, from: testing)
            return
        }
        WindowFrames.preserve(from: real, into: testing)
        let backup = testing.dictionary(forKey: WindowFrames.backupKey)
        testing.removePersistentDomain(forName: suite)
        testing.set(backup, forKey: WindowFrames.backupKey)
    }
}
