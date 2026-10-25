import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @State private var name = OnboardingView.defaultName

    static var defaultName: String {
        #if os(macOS)
        NSFullUserName()
        #else
        ""
        #endif
    }

    var body: some View {
        VStack(spacing: Spacing.s6) {
            VStack(spacing: Spacing.s2) {
                Text("Welcome to Tycho").tychoFont(.xxl, weight: .semibold)
                Text("A calm place for projects and tasks.")
                    .tychoFont(.md)
                    .foregroundStyle(Token.text3.color)
            }
            #if os(macOS)
            .focusable()
            .focusEffectDisabled()
            #endif
            VStack(alignment: .leading, spacing: Spacing.s2) {
                Text("Your name").tychoFont(.xs, weight: .medium).foregroundStyle(Token.text3.color)
                TextField("Your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("onboarding.name")
            }
            .frame(maxWidth: 320)
            HStack(spacing: Spacing.s3) {
                Button("Start empty") {
                    toast.perform { try EmptySeed.load(into: context, ownerName: name) }
                }
                .buttonStyle(.tycho(.primary, size: .lg))
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("onboarding.empty")
                Button("Load demo") {
                    toast.perform { try DemoSeed.load(into: context, now: .now, calendar: .current, ownerName: name) }
                }
                .buttonStyle(.tycho(.secondary, size: .lg))
                .accessibilityIdentifier("onboarding.demo")
            }
        }
        .padding(Spacing.s10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Token.bg.color)
    }
}
