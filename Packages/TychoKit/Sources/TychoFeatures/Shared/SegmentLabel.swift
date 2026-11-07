import SwiftUI

struct SegmentLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .accessibilityLabel(title)
            .help(title)
    }
}
