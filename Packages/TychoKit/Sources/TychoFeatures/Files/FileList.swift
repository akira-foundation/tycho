import SwiftUI
import TychoCore

struct FileList: View {
    let files: [FileRecord]
    let actions: (FileRecord) -> FileMenuActions

    var body: some View {
        List(files) { file in
            FileRow(file: file, actions: actions(file))
        }
    }
}

struct FileRow: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    @Environment(\.isCompactWidth) private var isCompactWidth
    let file: FileRecord
    let actions: FileMenuActions

    var body: some View {
        HStack(spacing: 12) {
            FileThumbnail(file: file)
                .frame(width: 44, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).lineLimit(1)
                Text(FileMessages.meta(file, dateText: dateText))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if let task = file.task {
                taskLink(task)
            }
            FileMenuButton(actions: actions)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: actions.preview)
        .contextMenu { FileMenuItems(actions: actions) }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Preview", actions.preview)
        .accessibilityIdentifier("file.\(file.name)")
    }

    @ViewBuilder private func taskLink(_ task: TaskItem) -> some View {
        let link = Button(task.key, systemImage: "link") { router.inspect(task.id) }
            .buttonStyle(.borderless)
            .font(.caption.monospaced())
        if isCompactWidth {
            link.labelStyle(.iconOnly)
        } else {
            link
        }
    }
}
