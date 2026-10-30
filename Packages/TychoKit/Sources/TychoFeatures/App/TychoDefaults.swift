import Foundation

public enum TychoDefaults {
    public static let uiTestingSuite = "io.akira.tycho.uitesting"

    nonisolated(unsafe) public static let current = store(arguments: ProcessInfo.processInfo.arguments)

    static func isUITesting(_ arguments: [String]) -> Bool {
        arguments.contains("-uiTesting")
    }

    static func store(arguments: [String], suite: String = uiTestingSuite) -> UserDefaults {
        guard isUITesting(arguments), let testing = UserDefaults(suiteName: suite) else { return .standard }
        return testing
    }

    public static func resetIfTesting(
        arguments: [String] = ProcessInfo.processInfo.arguments, suite: String = uiTestingSuite
    ) {
        guard isUITesting(arguments) else { return }
        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
    }
}
