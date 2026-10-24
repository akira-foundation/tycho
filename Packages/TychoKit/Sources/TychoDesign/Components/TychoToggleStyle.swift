import SwiftUI

public struct TychoToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer(minLength: Spacing.s2)
            Track(isOn: configuration.isOn) { configuration.isOn.toggle() }
        }
    }

    private struct Track: View {
        let isOn: Bool
        let action: () -> Void
        @Environment(\.accent) private var accent
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            Button(action: action) {
                Capsule()
                    .fill(isOn ? accent.color : Token.borderStrong.color)
                    .frame(width: 30, height: 18)
                    .overlay(alignment: .leading) {
                        Circle().fill(.white).frame(width: 14, height: 14)
                            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                            .offset(x: isOn ? 14 : 2)
                    }
                    .animation(.easeOut(duration: 0.14), value: isOn)
            }
            .buttonStyle(.plain)
            .opacity(isEnabled ? 1 : 0.45)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(isOn ? "1" : "0")
        }
    }
}
