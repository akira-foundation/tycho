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
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                TychoMark(size: 96)
                    .accessibilityHidden(true)
                    .padding(.bottom, 8)
                Text("Welcome to Tycho").font(.largeTitle.bold())
                Text("A calm place for projects and tasks.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            #if os(macOS)
            .focusable()
            .focusEffectDisabled()
            #endif
            TextField("Your Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .marksTextEditing()
                .frame(maxWidth: 320)
                .accessibilityIdentifier("onboarding.name")
            VStack(spacing: 12) {
                Button("Start Empty") {
                    toast.perform { try EmptySeed.load(into: context, ownerName: name) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("onboarding.empty")
                Button("Load Demo") {
                    toast.perform { try DemoSeed.load(into: context, now: .now, calendar: .current, ownerName: name) }
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("onboarding.demo")
            }
            .controlSize(.large)
            .frame(maxWidth: 320)
            .buttonSizing(.flexible)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
