import SwiftUI

public enum Motion {
    public static let duration: Double = 0.14
    public static let ease = Animation.timingCurve(0.23, 1, 0.32, 1, duration: duration)
    public static let spring = Animation.timingCurve(0.34, 1.56, 0.64, 1, duration: duration)
    public static let easeDrawer = Animation.timingCurve(0.32, 0.72, 0, 1, duration: 0.3)

    public static func animation(_ animation: Animation, preference: MotionPreference, reduceMotion: Bool) -> Animation?
    {
        switch preference {
        case .reduce: nil
        case .full: animation
        case .system: reduceMotion ? nil : animation
        }
    }
}
