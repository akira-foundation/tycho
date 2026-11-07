import SwiftUI
import TychoCore

struct FileGrid: View {
    let files: [FileRecord]
    let actions: (FileRecord) -> FileMenuActions

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20, alignment: .top)], spacing: 24) {
                ForEach(files) { FileCard(file: $0, actions: actions($0)) }
            }
            .padding()
        }
    }
}

struct FileCard: View {
    @Environment(\.dateText) private var dateText
    let file: FileRecord
    let actions: FileMenuActions

    var body: some View {
        VStack(spacing: 6) {
            FileThumbnail(file: file)
                .aspectRatio(4 / 3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(file.name).font(.callout).lineLimit(2).multilineTextAlignment(.center)
            Text(FileMessages.meta(file, dateText: dateText))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: actions.preview)
        .contextMenu { FileMenuItems(actions: actions) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Preview", actions.preview)
        .accessibilityIdentifier("file.\(file.name)")
    }
}
