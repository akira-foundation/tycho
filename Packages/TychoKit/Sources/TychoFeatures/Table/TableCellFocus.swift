import SwiftUI

extension View {
    func focusedOnceTheTableReleasesTheClick(_ focused: FocusState<Bool>.Binding) -> some View {
        task {
            await withCheckedContinuation { continuation in
                RunLoop.main.perform(inModes: [.default]) { continuation.resume() }
            }
            guard !Task.isCancelled else { return }
            focused.wrappedValue = true
        }
    }
}
