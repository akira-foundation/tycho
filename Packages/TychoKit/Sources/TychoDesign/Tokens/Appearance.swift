import SwiftUI

public enum ThemePreference: String, CaseIterable, Sendable, Identifiable {
    case system, light, dark

    public var id: String { rawValue }
    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

public enum MotionPreference: String, CaseIterable, Sendable, Identifiable {
    case system, reduce, full

    public var id: String { rawValue }
    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}

extension EnvironmentValues {
    @Entry public var density: Density = .comfortable
    @Entry public var motionPreference: MotionPreference = .system
}
