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

    var body: some View {
        let files = task.orderedAttachments
        Section {
            ForEach(files) { file in
                Button {
                    previewing = file
                } label: {
                    AttachmentCard(file: file)
                }
                .buttonStyle(.plain)
            }
            Button("Add Attachment…", systemImage: "paperclip") { importing = true }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("inspector.attachments.add")
        } header: {
            HStack {
                Text("Attachments")
                Spacer()
                Text("\(files.count)").monospacedDigit()
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            upload(urls)
            return !urls.isEmpty
        }
        .fileUploader(isPresented: $importing, task: task)
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
        HStack(spacing: 10) {
            FileThumbnail(file: file)
                .frame(width: 40, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).lineLimit(1)
                Text(Self.caption(for: file)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("attachment.\(file.name)")
    }
}
