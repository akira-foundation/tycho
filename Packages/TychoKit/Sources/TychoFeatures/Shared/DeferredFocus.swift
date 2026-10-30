import SwiftUI

enum RunLoopTurn {
    static func next() async {
        await withCheckedContinuation { continuation in
            RunLoop.main.perform(inModes: [.default]) { continuation.resume() }
        }
    }
}

extension View {
    func focusedOnTheNextRunLoopTurn(_ focused: FocusState<Bool>.Binding) -> some View {
        task {
            await RunLoopTurn.next()
            guard !Task.isCancelled else { return }
            focused.wrappedValue = true
        }
    }
}
