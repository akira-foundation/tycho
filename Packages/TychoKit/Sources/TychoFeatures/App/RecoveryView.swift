import SwiftUI

struct RecoveryView: View {
    let message: String
    let retry: () -> Void
    let reset: () -> Void
    @State private var confirmingReset = false

    var body: some View {
        ContentUnavailableView {
            Label("Tycho Couldn't Open Its Data", systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
            Button("Reset Data…", role: .destructive) { confirmingReset = true }
                .buttonStyle(.bordered)
        }
        .confirmationDialog("Delete All Tycho Data on This Device?", isPresented: $confirmingReset) {
            Button("Delete and Start Over", role: .destructive, action: reset)
        } message: {
            Text("This can't be undone.")
        }
    }
}
