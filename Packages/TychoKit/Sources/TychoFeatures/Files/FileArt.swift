import SwiftData
import SwiftUI
import TychoCore

struct FileThumbnail: View {
    @Environment(\.modelContext) private var context
    let file: FileRecord
    @State private var decoded: CGImage?

    private struct TaskKey: Hashable {
        let id: UUID
        let kind: FileKind
    }

    var body: some View {
        ZStack {
            Rectangle().fill(.fill.tertiary)
            if let decoded {
                Image(decorative: decoded, scale: 1).resizable().scaledToFill()
            } else {
                Image(systemName: file.kind.symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(file.kind.tint)
                    .frame(maxWidth: 44, maxHeight: 44)
                    .padding(8)
            }
        }
        .clipped()
        .task(id: TaskKey(id: file.id, kind: file.kind)) { await decodeImage() }
    }

    private func decodeImage() async {
        guard file.kind == .img, file.hasData else {
            decoded = nil
            return
        }
        let image = await ThumbnailDecoder.thumbnail(forFileID: file.id, container: context.container)
        guard !Task.isCancelled else { return }
        decoded = image
    }
}
