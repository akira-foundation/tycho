import SwiftUI
import TychoCore
import TychoDesign

public enum AppearanceKey {
    public static let theme = "appearance.theme"
    public static let density = "appearance.density"
    public static let motion = "appearance.motion"
    public static let weekStart = "preferences.weekStart"
    public static let dateFormat = "preferences.dateFormat"
}

struct AppearanceModifier: ViewModifier {
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system
    @AppStorage(AppearanceKey.density) private var density = Density.comfortable
    @AppStorage(AppearanceKey.motion) private var motion = MotionPreference.system
    @AppStorage(AppearanceKey.weekStart) private var weekStart = WeekStart.monday
    @AppStorage(AppearanceKey.dateFormat) private var dateFormat = DateFormatPreference.monthDay

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(theme.colorScheme)
            .environment(\.density, density)
            .environment(\.motionPreference, motion)
            .environment(\.weekStart, weekStart)
            .environment(\.dateText, DateText(format: dateFormat))
    }
}

extension View {
    public func tychoAppearance() -> some View { modifier(AppearanceModifier()) }
}
