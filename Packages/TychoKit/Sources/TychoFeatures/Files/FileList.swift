import SwiftUI
import TychoCore
import TychoDesign

enum FileListColumns {
    static let type: CGFloat = 110
    static let size: CGFloat = 80
    static let uploader: CGFloat = 170
    static let date: CGFloat = 100
    static let minimumWidth: CGFloat = 680
}

struct FileList: View {
    let files: [FileRecord]
    let actions: (FileRecord) -> FileMenuActions

    var body: some View {
        ScrollView(.horizontal) {
            VStack(spacing: 0) {
                header
                Divider()
                ForEach(files) { file in
                    FileRow(file: file, actions: actions(file))
                    Divider()
                }
            }
            .containerRelativeFrame(.horizontal) { length, _ in max(length, FileListColumns.minimumWidth) }
        }
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: Spacing.s3) {
            Text("Name").frame(maxWidth: .infinity, alignment: .leading)
            Text("Type").frame(width: FileListColumns.type, alignment: .leading)
            Text("Size").frame(width: FileListColumns.size, alignment: .leading)
            Text("Uploaded by").frame(width: FileListColumns.uploader, alignment: .leading)
            Text("Date").frame(width: FileListColumns.date, alignment: .leading)
            Color.clear.frame(width: 28)
        }
        .tychoFont(.xs, weight: .medium)
        .foregroundStyle(Token.text3.color)
        .padding(.horizontal, Spacing.s3)
        .frame(height: 32)
    }
}

struct FileRow: View {
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    let file: FileRecord
    let actions: FileMenuActions

    var body: some View {
        HStack(spacing: Spacing.s3) {
            HStack(spacing: Spacing.s2) {
                Image(systemName: file.kind.symbol).foregroundStyle(file.kind.tint).frame(width: 22)
                Text(file.name).tychoFont(.sm, weight: .medium).lineLimit(1)
                if let task = file.task {
                    Button(task.key, systemImage: "link") { router.inspect(task.id) }
                        .tychoFont(.xxs, design: .monospaced)
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(file.kind.title).frame(width: FileListColumns.type, alignment: .leading)
            Text(file.sizeText).monospacedDigit().frame(width: FileListColumns.size, alignment: .leading)
            HStack(spacing: Spacing.s1) {
                if let member = file.uploadedBy {
                    Avatar(initials: member.initials, color: member.tint, size: 18)
                }
                Text(file.uploadedBy?.name ?? "You").lineLimit(1)
            }
            .frame(width: FileListColumns.uploader, alignment: .leading)
            Text(dateText.ago(file.uploadedAt)).frame(width: FileListColumns.date, alignment: .leading)
            FileMenuButton(actions: actions).frame(width: 28)
        }
        .tychoFont(.sm)
        .foregroundStyle(Token.text2.color)
        .padding(.horizontal, Spacing.s3)
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture(perform: actions.preview)
        .contextMenu { FileMenuItems(actions: actions) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("file.\(file.name)")
    }
}
