import SwiftUI

extension EnvironmentValues {
    var isCompactWidth: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}
