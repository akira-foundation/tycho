import SwiftUI
import TychoCore
import TychoDesign

struct FileGrid: View {
    let files: [FileRecord]
    let actions: (FileRecord) -> FileMenuActions

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: Spacing.s4)], spacing: Spacing.s4) {
            ForEach(files) { FileCard(file: $0, actions: actions($0)) }
        }
    }
}

struct FileCard: View {
    @Environment(\.dateText) private var dateText
    let file: FileRecord
    let actions: FileMenuActions

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FileThumbnail(file: file).aspectRatio(16 / 10, contentMode: .fit)
            Divider()
            HStack(alignment: .top, spacing: Spacing.s2) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name).tychoFont(.sm, weight: .medium).lineLimit(1)
                    Text(FileMessages.meta(file, dateText: dateText))
                        .tychoFont(.xxs)
                        .foregroundStyle(Token.text3.color)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                FileMenuButton(actions: actions)
            }
            .padding(Spacing.s3)
        }
        .background(Token.surface.color)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .shadowCard(radius: Radius.lg)
        .contentShape(Rectangle())
        .onTapGesture(perform: actions.preview)
        .contextMenu { FileMenuItems(actions: actions) }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Preview", actions.preview)
        .accessibilityIdentifier("file.\(file.name)")
    }
}
