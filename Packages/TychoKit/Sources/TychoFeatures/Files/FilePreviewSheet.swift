import QuickLook
import SwiftUI
import TychoCore
import TychoDesign

struct FilePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.dateText) private var dateText
    let file: FileRecord
    @State private var quickLookURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(file.name).tychoFont(.lg, weight: .semibold)
                Text(FileMessages.previewSubtitle(file, dateText: dateText))
                    .tychoFont(.sm)
                    .foregroundStyle(Token.text3.color)
            }
            FileThumbnail(file: file)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous).strokeBorder(Token.border.color))
            if let task = file.task {
                HStack(spacing: Spacing.s1) {
                    Image(systemName: "link")
                    Text("Attached to")
                    Button(task.title) {
                        router.inspect(task.id)
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
                .tychoFont(.sm)
                .foregroundStyle(Token.text3.color)
            }
            HStack {
                Button("Copy link", systemImage: "link") {
                    Pasteboard.copy(FileMessages.link(file))
                    toast.show("Link copied")
                }
                if file.hasData {
                    Button("Quick Look", systemImage: "eye", action: openQuickLook)
                }
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(Spacing.s6)
        .frame(minWidth: 480)
        .quickLookPreview($quickLookURL)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("file.preview")
    }

    private func openQuickLook() {
        do {
            quickLookURL = try FileQuickLook.temporaryURL(for: file)
        } catch {
            toast.report(error)
        }
    }
}
