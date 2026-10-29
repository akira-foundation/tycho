import SwiftUI
import TychoDesign

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension ThemePreference {
    static func toggled(isDark: Bool) -> ThemePreference { isDark ? .light : .dark }

    @MainActor var resolvesDark: Bool {
        switch self {
        case .dark: true
        case .light: false
        case .system: Self.systemIsDark
        }
    }

    @MainActor private static var systemIsDark: Bool {
        #if os(macOS)
        NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        #else
        UITraitCollection.current.userInterfaceStyle == .dark
        #endif
    }
}
