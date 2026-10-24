import Foundation
import ImageIO
import SwiftData
import Testing
import UniformTypeIdentifiers

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct FilesFeatureTests {
    private let context: ModelContext
    private let utc: Calendar
    private let now = Date(timeIntervalSince1970: 1_791_892_800)

    init() throws {
        context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        utc = calendar
    }

    private func file(_ name: String, minutesAgo: Double, by member: Member? = nil) -> FileRecord {
        let file = FileRecord(name: name, byteCount: 2048, uploadedAt: now.addingTimeInterval(-minutesAgo * 60))
        context.insert(file)
        file.uploadedBy = member
        return file
    }

    @Test func searchIgnoresCaseAndKindsFilter() {
        let files = [
            file("Hero.png", minutesAgo: 5), file("brief.pdf", minutesAgo: 10), file("hero-notes.md", minutesAgo: 1),
        ]
        #expect(
            FileQuery.apply(files, search: "HERO", kind: nil, sort: .newest).map(\.name) == [
                "hero-notes.md", "Hero.png",
            ])
        #expect(FileQuery.apply(files, search: "", kind: .pdf, sort: .newest).map(\.name) == ["brief.pdf"])
        #expect(!FileQuery.isFiltering(search: "", kind: nil))
        #expect(FileQuery.isFiltering(search: "a", kind: nil))
        #expect(FileQuery.isFiltering(search: "", kind: .img))
        #expect(FileQuery.filterKinds == [.fig, .pdf, .zip, .img, .sheet, .doc, .code])
    }

    @Test func sortsByNewestNameOrType() {
        let files = [file("b.pdf", minutesAgo: 30), file("a.png", minutesAgo: 20), file("c.pdf", minutesAgo: 10)]
        #expect(
            FileQuery.apply(files, search: "", kind: nil, sort: .newest).map(\.name) == ["c.pdf", "a.png", "b.pdf"])
        #expect(FileQuery.apply(files, search: "", kind: nil, sort: .name).map(\.name) == ["a.png", "b.pdf", "c.pdf"])
        #expect(FileQuery.apply(files, search: "", kind: nil, sort: .type).map(\.name) == ["a.png", "c.pdf", "b.pdf"])
        #expect(FileSort.allCases.map(\.title) == ["Sort: Newest", "Sort: Name", "Sort: Type"])
    }

    @Test func messagesFollowTheOriginal() {
        let sarah = Member(name: "Sarah Chen", email: "")
        context.insert(sarah)
        let text = DateText(format: .monthDay, now: now, calendar: utc)
        let attached = file("wireframes.fig", minutesAgo: 300, by: sarah)
        let task = TaskItem(number: 9, title: "Wireframes")
        context.insert(task)
        attached.task = task
        let loose = file("notes.md", minutesAgo: 30)

        #expect(FileMessages.meta(attached, dateText: text) == "2 KB · Sarah · 5h ago")
        #expect(
            FileMessages.previewSubtitle(attached, dateText: text) == "Figma · 2 KB · Uploaded by Sarah Chen 5h ago")
        #expect(FileMessages.previewSubtitle(loose, dateText: text) == "Document · 2 KB · Uploaded by you 30m ago")
        #expect(FileMessages.deleteMessage(attached) == "wireframes.fig will be removed from the project and its task.")
        #expect(FileMessages.deleteMessage(loose) == "notes.md will be removed from the project.")
        #expect(FileMessages.link(loose) == "tycho://file/\(loose.id.uuidString)")
    }

    @Test func quickLookWritesATemporaryCopyOnlyWhenThereIsContent() throws {
        let record = file("brief.pdf", minutesAgo: 1)
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        #expect(throws: FileQuickLook.MissingContent.self) { try FileQuickLook.temporaryURL(for: record, in: base) }

        record.data = Data("hello".utf8)
        record.hasData = true
        let url = try FileQuickLook.temporaryURL(for: record, in: base)

        #expect(url.lastPathComponent == "brief.pdf")
        #expect(try Data(contentsOf: url) == Data("hello".utf8))
        try FileManager.default.removeItem(at: base)
    }

    @Test func cleanupRemovesOneCopyAndSweepRemovesAll() throws {
        let first = file("a.pdf", minutesAgo: 1)
        let second = file("b.pdf", minutesAgo: 2)
        for record in [first, second] {
            record.data = Data("x".utf8)
            record.hasData = true
        }
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        let firstURL = try FileQuickLook.temporaryURL(for: first, in: base)
        let secondURL = try FileQuickLook.temporaryURL(for: second, in: base)

        FileQuickLook.cleanUp(first, in: base)
        #expect(!FileManager.default.fileExists(atPath: firstURL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: secondURL.path(percentEncoded: false)))

        FileQuickLook.sweep(in: base)
        #expect(!FileManager.default.fileExists(atPath: secondURL.path(percentEncoded: false)))
        #expect(
            !FileManager.default.fileExists(atPath: base.appending(path: "tycho-files").path(percentEncoded: false)))
    }

    @Test(arguments: [".", "..", "", "a/b.pdf"])
    func temporaryNamesAreSanitised(name: String) throws {
        let record = file("x", minutesAgo: 1)
        record.name = name
        record.data = Data("x".utf8)
        record.hasData = true
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }

        let url = try FileQuickLook.temporaryURL(for: record, in: base)

        #expect(url.lastPathComponent == (name == "a/b.pdf" ? "a-b.pdf" : "file"))
        #expect(url.deletingLastPathComponent().lastPathComponent == record.id.uuidString)
    }

    private func encodedImage(_ type: UTType, side: Int = 400) -> Data {
        let space = CGColorSpaceCreateDeviceRGB()
        let bitmap = CGContext(
            data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let output = NSMutableData()
        let destination = CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, bitmap.makeImage()!, nil)
        CGImageDestinationFinalize(destination)
        return output as Data
    }

    @Test func thumbnailsAreDownscaledAndInvalidDataIsRejected() throws {
        let thumbnail = try #require(ThumbnailDecoder.decode(encodedImage(.png), maxPixelSize: 100))

        #expect(thumbnail.width == 100)
        #expect(ThumbnailDecoder.decode(Data("nope".utf8), maxPixelSize: 100) == nil)
    }

    @Test func decoderAcceptsOnlyTheAllowedImageTypes() {
        let allowed = [UTType.png, .jpeg, .tiff, .gif].map {
            ThumbnailDecoder.decode(encodedImage($0), maxPixelSize: 50)
        }
        #expect(allowed.allSatisfy { $0 != nil })
        #expect(ThumbnailDecoder.decode(encodedImage(.bmp), maxPixelSize: 50) == nil)
    }

    @Test func decoderUsesTheFileNameAsATypeHint() {
        let png = encodedImage(.png)
        #expect(ThumbnailDecoder.decode(png, maxPixelSize: 50, fileName: "hero.png") != nil)
        #expect(ThumbnailDecoder.decode(png, maxPixelSize: 50, fileName: "noext") != nil)
    }

    @Test func thumbnailLoadsFromABackgroundContextWithoutFaultingTheMainContext() async throws {
        let container = try TychoSchema.makeContainer(inMemory: true)
        let main = container.mainContext
        let record = FileRecord(name: "hero.png", byteCount: 10, uploadedAt: now)
        record.data = encodedImage(.png)
        record.hasData = true
        main.insert(record)
        try main.save()

        let image = await ThumbnailDecoder.thumbnail(for: record.persistentModelID, container: container)

        #expect(image != nil)
        let doc = FileRecord(name: "brief.pdf", byteCount: 10, uploadedAt: now)
        doc.data = Data("x".utf8)
        doc.hasData = true
        main.insert(doc)
        try main.save()
        let none = await ThumbnailDecoder.thumbnail(for: doc.persistentModelID, container: container)
        #expect(none == nil)
    }
}
