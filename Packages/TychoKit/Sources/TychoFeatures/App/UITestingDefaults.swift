import Foundation

@MainActor
public enum UITestingDefaults {
    public static func resetIfTesting(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        defaults: UserDefaults = .standard,
        domain: String? = Bundle.main.bundleIdentifier
    ) {
        guard StoreLoader.usesMemory(arguments: arguments), let domain,
            let stored = defaults.persistentDomain(forName: domain)
        else { return }
        for key in stored.keys where !key.hasPrefix("NS") {
            defaults.removeObject(forKey: key)
        }
    }
}
