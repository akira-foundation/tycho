import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct AttachmentsSection: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    @State private var importing = false
    @State private var previewing: FileRecord?
    private let columns = [GridItem(.adaptive(minimum: 140), spacing: Spacing.s2)]

    var body: some View {
        let files = task.orderedAttachments
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack {
                Text("Attachments").tychoFont(.sm, weight: .semibold)
                Text("\(files.count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
                Spacer()
                Button("Upload", systemImage: "arrow.up.doc") { importing = true }
                    .buttonStyle(.borderless)
            }
            if !files.isEmpty {
                LazyVGrid(columns: columns, spacing: Spacing.s2) {
                    ForEach(files) { file in
                        Button {
                            previewing = file
                        } label: {
                            AttachmentCard(file: file)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            FileDropzone(
                message: "Drop files or click to attach", onBrowse: { importing = true }, onDrop: upload,
                identifier: "inspector.attachments.dropzone")
        }
        .fileUploader(isPresented: $importing, project: task.project, task: task)
        .filePreview(item: $previewing)
    }

    private func upload(_ urls: [URL]) {
        FileUpload.perform(urls, project: task.project, task: task, context: context, toast: toast)
    }
}

struct AttachmentCard: View {
    let file: FileRecord

    static func caption(for file: FileRecord) -> String { "\(file.kind.title) · \(file.sizeText)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FileThumbnail(file: file).aspectRatio(16 / 10, contentMode: .fit)
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).tychoFont(.xs, weight: .medium).lineLimit(1)
                Text(Self.caption(for: file)).tychoFont(.xxs).foregroundStyle(Token.text4.color)
            }
            .padding(Spacing.s2)
        }
        .background(Token.surface2.color)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous).strokeBorder(Token.border.color))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("attachment.\(file.name)")
    }
}
