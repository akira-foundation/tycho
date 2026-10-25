import SwiftUI

public struct TychoToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Row(isOn: configuration.isOn, label: configuration.label) { configuration.isOn.toggle() }
    }

    private struct Row<Label: View>: View {
        let isOn: Bool
        let label: Label
        let action: () -> Void
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            Button(action: action) {
                HStack {
                    label
                    Spacer(minLength: Spacing.s2)
                    track
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .opacity(isEnabled ? 1 : 0.45)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(isOn ? "On" : "Off")
        }

        private var track: some View {
            Capsule()
                .fill(isOn ? Color.accentColor : Token.borderStrong.color)
                .frame(width: 30, height: 18)
                .overlay(alignment: .leading) {
                    Circle().fill(.white).frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                        .offset(x: isOn ? 14 : 2)
                }
                .animation(.easeOut(duration: 0.14), value: isOn)
        }
    }
}
