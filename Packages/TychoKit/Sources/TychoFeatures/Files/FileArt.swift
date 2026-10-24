import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct FileThumbnail: View {
    @Environment(\.modelContext) private var context
    let file: FileRecord
    @State private var decoded: CGImage?

    private struct TaskKey: Hashable {
        let id: UUID
        let kind: FileKind
    }

    var body: some View {
        let showsImage = decoded != nil
        ZStack(alignment: .bottomLeading) {
            Token.surface2.color
            if let decoded {
                Image(decorative: decoded, scale: 1).resizable().scaledToFill()
            } else {
                FileArt(kind: file.kind)
            }
            if !showsImage && !file.fileExtension.isEmpty {
                Text(String(file.fileExtension.prefix(4)))
                    .tychoFont(.xxs, weight: .semibold, design: .monospaced)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(file.kind.tint, in: RoundedRectangle(cornerRadius: Radius.xs))
                    .padding(Spacing.s2)
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

struct FileArt: View {
    let kind: FileKind

    var body: some View {
        switch kind {
        case .img:
            ImageArt(tint: kind.tint)
        case .sheet:
            SheetArt(tint: kind.tint)
        case .fig:
            FigmaArt(tint: kind.tint)
        case .zip:
            Image(systemName: kind.symbol)
                .font(.system(size: 30))
                .foregroundStyle(kind.tint)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .pdf, .doc, .code, .other:
            LinesArt()
        }
    }
}

private struct ImageArt: View {
    let tint: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [tint.opacity(0.35), tint.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.47))
                    path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.77))
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.53))
                    path.addLine(to: CGPoint(x: width, y: height * 0.97))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(tint.opacity(0.45))
                Circle()
                    .fill(tint.opacity(0.3))
                    .frame(width: height * 0.23, height: height * 0.23)
                    .position(x: width * 0.76, y: height * 0.27)
            }
        }
    }
}

private struct SheetArt: View {
    let tint: Color

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 4), spacing: 3) {
            ForEach(0..<20, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1).fill(tint.opacity(0.22)).frame(height: 8)
            }
        }
        .padding(Spacing.s4)
    }
}

private struct FigmaArt: View {
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 5) {
                Capsule().fill(Token.borderStrong.color).frame(height: 6)
                Capsule().fill(Token.border.color).frame(height: 5)
                Capsule().fill(Token.border.color).frame(width: 60, height: 5)
                RoundedRectangle(cornerRadius: 3).fill(tint.opacity(0.2)).frame(height: 18)
            }
            RoundedRectangle(cornerRadius: 3).fill(tint.opacity(0.14)).frame(width: 48)
        }
        .padding(Spacing.s4)
    }
}

private struct LinesArt: View {
    private static let widths: [CGFloat] = [0.5, 1, 1, 0.8, 1, 0.6]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Array(Self.widths.enumerated()), id: \.offset) { index, fraction in
                Capsule()
                    .fill(index == 0 ? Token.borderStrong.color : Token.border.color)
                    .frame(height: index == 0 ? 7 : 5)
                    .scaleEffect(x: fraction, anchor: .leading)
            }
        }
        .padding(Spacing.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
