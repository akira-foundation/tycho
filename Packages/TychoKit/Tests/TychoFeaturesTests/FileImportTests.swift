import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct FileImportTests {
    private let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)

    init() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func write(_ name: String, _ text: String) throws -> URL {
        let url = directory.appending(path: name)
        try Data(text.utf8).write(to: url)
        return url
    }

    @Test func readsTheNameAndTheContent() throws {
        let url = try write("brief.pdf", "hello")
        let (name, data) = try FileImport.read(url)
        #expect(name == "brief.pdf")
        #expect(data == Data("hello".utf8))
    }

    @Test func rejectsAFolder() throws {
        let folder = directory.appending(path: "assets")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        #expect(throws: ValidationError.unsupportedFile) { try FileImport.read(folder) }
    }

    @Test func rejectsFilesOverTheLimitBeforeReadingThem() throws {
        let url = directory.appending(path: "huge.zip")
        FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        try handle.truncate(atOffset: UInt64(FileActions.maxByteCount + 1))
        try handle.close()
        #expect(throws: ValidationError.fileTooLarge) { try FileImport.read(url) }
    }

    @Test func acceptsAFileOfExactlyTheMaximumSize() throws {
        let url = directory.appending(path: "edge.zip")
        FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        try handle.truncate(atOffset: UInt64(FileActions.maxByteCount))
        try handle.close()
        let (name, data) = try FileImport.read(url)
        #expect(name == "edge.zip")
        #expect(data.count == FileActions.maxByteCount)
    }

    @Test func uploadStoresEachFileAndReportsTheRest() throws {
        let context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        let toast = ToastCenter()

        FileUpload.perform(
            [try write("hero.png", "img")], project: project, task: nil, context: context, toast: toast)
        #expect(project.files?.map(\.name) == ["hero.png"])
        #expect(project.files?.first?.hasData == true)
        #expect(toast.message == "Uploaded hero.png")

        FileUpload.perform([directory], project: project, task: nil, context: context, toast: toast)
        #expect(toast.message == "Only files can be uploaded.")
        #expect(project.files?.count == 1)
    }
}
