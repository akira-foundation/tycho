import Foundation
import ImageIO
import SwiftData
import Testing
import UniformTypeIdentifiers

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct FilesFeatureTests {
    private let container: ModelContainer
    private let context: ModelContext
    private let utc: Calendar
    private let now = Date(timeIntervalSince1970: 1_791_892_800)

    init() throws {
        container = try TychoSchema.makeContainer(inMemory: true)
        context = ModelContext(container)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        utc = calendar
    }

    private func quickLookURL(_ record: FileRecord, in base: URL) async throws -> URL {
        try context.save()
        return try await FileQuickLook.temporaryURL(forFileID: record.id, container: container, in: base)
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

    @Test func quickLookWritesATemporaryCopyOnlyWhenThereIsContent() async throws {
        let record = file("brief.pdf", minutesAgo: 1)
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        await #expect(throws: FileQuickLook.MissingContent.self) { try await quickLookURL(record, in: base) }

        record.data = Data("hello".utf8)
        record.hasData = true
        let url = try await quickLookURL(record, in: base)

        #expect(url.lastPathComponent == "brief.pdf")
        #expect(try Data(contentsOf: url) == Data("hello".utf8))
        try FileManager.default.removeItem(at: base)
    }

    @Test func cleanupRemovesOnePresentationCopyAndSweepRemovesAll() async throws {
        let record = file("a.pdf", minutesAgo: 1)
        record.data = Data("x".utf8)
        record.hasData = true
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        let firstURL = try await quickLookURL(record, in: base)
        let secondURL = try await quickLookURL(record, in: base)
        #expect(firstURL.deletingLastPathComponent() != secondURL.deletingLastPathComponent())

        FileQuickLook.cleanUp(firstURL)
        #expect(!FileManager.default.fileExists(atPath: firstURL.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: secondURL.path(percentEncoded: false)))

        FileQuickLook.sweep(in: base)
        #expect(!FileManager.default.fileExists(atPath: secondURL.path(percentEncoded: false)))
        #expect(
            !FileManager.default.fileExists(atPath: base.appending(path: "tycho-files").path(percentEncoded: false)))
    }

    @Test func cleanupIgnoresURLsOutsideTheQuickLookFolder() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "keep.txt")
        try Data("x".utf8).write(to: url)

        FileQuickLook.cleanUp(url)

        #expect(FileManager.default.fileExists(atPath: url.path(percentEncoded: false)))
    }

    @Test(arguments: [".", "..", "", "a/b.pdf"])
    func temporaryNamesAreSanitised(name: String) async throws {
        let record = file("x", minutesAgo: 1)
        record.name = name
        record.data = Data("x".utf8)
        record.hasData = true
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }

        let url = try await quickLookURL(record, in: base)

        let expected = name == "a/b.pdf" ? "a-b.pdf" : "file"
        #expect(url.lastPathComponent == expected)
    }

    @Test func nulBytesAreStrippedFromTemporaryNames() {
        #expect(FileQuickLook.safeName("nu\u{0}ll.txt") == "null.txt")
    }

    @Test func longNamesAreTruncatedKeepingTheExtension() async throws {
        let long = String(repeating: "é", count: 200) + ".pdf"
        let safe = FileQuickLook.safeName(long)
        #expect(safe.utf8.count <= FileQuickLook.maxNameByteCount)
        #expect(safe.hasSuffix(".pdf"))
        #expect(safe.hasPrefix("é"))

        let record = file("x", minutesAgo: 1)
        record.name = long
        record.data = Data("x".utf8)
        record.hasData = true
        let base = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        let url = try await quickLookURL(record, in: base)
        #expect(try Data(contentsOf: url) == Data("x".utf8))
        #expect(FileQuickLook.safeName("short.txt") == "short.txt")
        #expect(FileQuickLook.safeName(String(repeating: "a", count: 300)).utf8.count == 255)
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

        let image = await ThumbnailDecoder.thumbnail(forFileID: record.id, container: container)

        #expect(image != nil)
        let doc = FileRecord(name: "brief.pdf", byteCount: 10, uploadedAt: now)
        doc.data = Data("x".utf8)
        doc.hasData = true
        main.insert(doc)
        try main.save()
        let none = await ThumbnailDecoder.thumbnail(forFileID: doc.id, container: container)
        #expect(none == nil)
    }

    @Test func thumbnailOfADeletedFileIsNilWithoutCrashing() async throws {
        let container = try TychoSchema.makeContainer(inMemory: true)
        let main = container.mainContext
        let record = FileRecord(name: "gone.png", byteCount: 10, uploadedAt: now)
        record.data = encodedImage(.png)
        record.hasData = true
        main.insert(record)
        try main.save()
        let id = record.id
        main.delete(record)
        try main.save()

        #expect(await ThumbnailDecoder.thumbnail(forFileID: id, container: container) == nil)
        #expect(await ThumbnailDecoder.thumbnail(forFileID: UUID(), container: container) == nil)
    }

    @Test func heifIsAnAllowedType() {
        #expect(ThumbnailDecoder.isAllowed(UTType.heif.identifier))
        #expect(!ThumbnailDecoder.isAllowed(UTType.bmp.identifier))
    }
}
