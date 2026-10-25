import SwiftUI
import TychoCore
import TychoDesign

private struct MotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.motionPreference) private var preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let base: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(Motion.animation(base, preference: preference, reduceMotion: reduceMotion), value: value)
    }
}

extension View {
    func tychoAnimation<V: Equatable>(_ base: Animation = Motion.ease, value: V) -> some View {
        modifier(MotionModifier(base: base, value: value))
    }
}

extension Sequence where Element == TaskItem {
    var movementSignature: [String] {
        map { "\($0.id)|\($0.status.rawValue)|\($0.sortOrder)" }
    }
}
