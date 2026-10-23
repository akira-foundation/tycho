import SwiftUI
import TychoDesign

public enum AppearanceKey {
    public static let theme = "appearance.theme"
    public static let accent = "appearance.accent"
    public static let density = "appearance.density"
    public static let motion = "appearance.motion"
}

struct AppearanceModifier: ViewModifier {
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system
    @AppStorage(AppearanceKey.accent) private var accent = Accent.indigo
    @AppStorage(AppearanceKey.density) private var density = Density.comfortable
    @AppStorage(AppearanceKey.motion) private var motion = MotionPreference.system

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(theme.colorScheme)
            .tint(accent.color)
            .environment(\.accent, accent)
            .environment(\.density, density)
            .environment(\.motionPreference, motion)
    }
}

extension View {
    public func tychoAppearance() -> some View { modifier(AppearanceModifier()) }
}
