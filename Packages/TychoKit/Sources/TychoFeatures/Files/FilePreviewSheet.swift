import OSLog
import QuickLook
import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct FilePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.dateText) private var dateText
    let file: FileRecord
    @State private var quickLookURL: URL?
    @State private var copyURL: URL?
    private let logger = Logger(subsystem: "io.akira.tycho", category: "files")

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(file.name).font(.title3.weight(.semibold))
                Text(FileMessages.previewSubtitle(file, dateText: dateText))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            FileThumbnail(file: file)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            HStack {
                Button("Copy Link", systemImage: "link") {
                    Pasteboard.copy(FileMessages.link(file))
                    toast.show("Link copied")
                }
                if file.hasData {
                    Button("Quick Look", systemImage: "eye", action: openQuickLook)
                }
                Spacer()
                Button("Close", role: .close) { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(Spacing.s6)
        .frame(minWidth: 480)
        .quickLookPreview($quickLookURL)
        .onChange(of: quickLookURL) { _, url in
            if url == nil { removeCopy() }
        }
        .onDisappear(perform: removeCopy)
        .toastOverlay(toast)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("file.preview")
    }

    private func openQuickLook() {
        removeCopy()
        let fileID = file.id
        let container = context.container
        Task {
            do {
                let url = try await FileQuickLook.temporaryURL(forFileID: fileID, container: container)
                copyURL = url
                quickLookURL = url
            } catch {
                logger.error("Quick Look failed: \(error.localizedDescription, privacy: .public)")
                toast.show("Couldn't open preview.")
            }
        }
    }

    private func removeCopy() {
        guard let copyURL else { return }
        FileQuickLook.cleanUp(copyURL)
        self.copyURL = nil
    }
}
