import SwiftUI

extension View {
    func focusedOnceTheTableReleasesTheClick(_ focused: FocusState<Bool>.Binding) -> some View {
        task {
            await Task.yield()
            guard !Task.isCancelled else { return }
            focused.wrappedValue = true
        }
    }
}
