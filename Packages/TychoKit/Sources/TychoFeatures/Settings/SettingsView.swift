import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

public struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @AppStorage(AppearanceKey.theme) private var theme = ThemePreference.system
    @AppStorage(AppearanceKey.accent) private var accent = Accent.indigo
    @AppStorage(AppearanceKey.density) private var density = Density.comfortable
    @AppStorage(AppearanceKey.motion) private var motion = MotionPreference.system
    @State private var confirming: DataAction?

    enum DataAction: Identifiable {
        case reloadDemo, deleteAll
        var id: Self { self }
    }

    public init() {}

    public var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $theme) {
                    ForEach(ThemePreference.allCases) { Text($0.title).tag($0) }
                }
                Picker("Accent", selection: $accent) {
                    ForEach(Accent.allCases) { option in
                        Label(option.title, systemImage: "circle.fill").foregroundStyle(option.color).tag(option)
                    }
                }
                Picker("Density", selection: $density) {
                    ForEach(Density.allCases) { Text($0.title).tag($0) }
                }
                Picker("Motion", selection: $motion) {
                    ForEach(MotionPreference.allCases) { Text($0.title).tag($0) }
                }
            }
            Section("Data") {
                Button("Restore demo data…") { confirming = .reloadDemo }
                Button("Delete everything…", role: .destructive) { confirming = .deleteAll }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .confirmationDialog(
            confirming == .deleteAll ? "Delete all projects and tasks?" : "Replace your data with the demo workspace?",
            isPresented: Binding(get: { confirming != nil }, set: { if !$0 { confirming = nil } }),
            presenting: confirming
        ) { action in
            Button(action == .deleteAll ? "Delete everything" : "Replace with demo", role: .destructive) {
                router.closeInspector()
                router.open(.home)
                router.isShowingSettings = false
                toast.perform {
                    switch action {
                    case .reloadDemo: try DataReset.reloadDemo(in: context, now: .now, calendar: .current)
                    case .deleteAll: try DataReset.deleteAll(in: context)
                    }
                }
            }
        } message: { _ in
            Text("This can't be undone.")
        }
    }
}
