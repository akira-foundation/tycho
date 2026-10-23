import SwiftUI
import TychoDesign

struct RecoveryView: View {
    let message: String
    let retry: () -> Void
    let reset: () -> Void
    @State private var confirmingReset = false

    var body: some View {
        VStack(spacing: Spacing.s4) {
            EmptyState(
                title: "Tycho couldn't open its data", symbol: "externaldrive.badge.exclamationmark", message: message)
            HStack(spacing: Spacing.s3) {
                Button("Try again", action: retry).buttonStyle(.borderedProminent)
                Button("Reset data", role: .destructive) { confirmingReset = true }
            }
        }
        .padding(Spacing.s8)
        .confirmationDialog("Delete all Tycho data on this device?", isPresented: $confirmingReset) {
            Button("Delete and start over", role: .destructive, action: reset)
        } message: {
            Text("This can't be undone.")
        }
    }
}
