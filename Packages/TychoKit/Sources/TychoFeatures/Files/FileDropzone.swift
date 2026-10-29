import SwiftUI
import TychoDesign

struct FileDropzone: View {
    let message: String
    let onBrowse: () -> Void
    let onDrop: ([URL]) -> Void
    var identifier = "files.dropzone"
    @State private var targeted = false

    var body: some View {
        Button(action: onBrowse) {
            HStack(spacing: Spacing.s2) {
                Image(systemName: "icloud.and.arrow.up")
                Text(message)
            }
            .tychoFont(.sm)
            .foregroundStyle(Token.text3.color)
            .frame(maxWidth: .infinity)
            .padding(Spacing.s4)
            .background(
                targeted ? Token.surface3.color : Token.sunken.color,
                in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .strokeBorder(Token.borderStrong.color, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .dropDestination(for: URL.self) { urls, _ in
            onDrop(urls)
            return !urls.isEmpty
        } isTargeted: {
            targeted = $0
        }
        .accessibilityIdentifier(identifier)
    }
}
