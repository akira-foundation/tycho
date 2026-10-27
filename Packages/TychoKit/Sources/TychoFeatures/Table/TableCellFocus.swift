import SwiftUI

extension View {
    func focusedOnceTheTableReleasesTheClick(_ focused: FocusState<Bool>.Binding) -> some View {
        task {
            try? await Task.sleep(for: .milliseconds(150))
            focused.wrappedValue = true
        }
    }
}
