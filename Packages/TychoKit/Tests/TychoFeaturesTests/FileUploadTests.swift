import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct FileUploadTests {
    private let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    private let context: ModelContext
    private let project: Project
    private let toast = ToastCenter()

    init() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        project = Project(key: "WEB", name: "Website")
        context.insert(project)
    }

    private func write(_ name: String) throws -> URL {
        let url = directory.appending(path: name)
        try Data(name.utf8).write(to: url)
        return url
    }

    @Test func summarisesAnAllSuccessfulBatch() throws {
        let urls = [try write("a.png"), try write("b.png"), try write("c.png")]
        FileUpload.perform(urls, project: project, task: nil, context: context, toast: toast)
        #expect(toast.message == "Uploaded 3 files")
        #expect(project.files?.count == 3)
    }

    @Test func keepsTheFirstFailureAndCountsTheUploaded() throws {
        let urls = [try write("a.png"), directory, try write("b.png")]
        FileUpload.perform(urls, project: project, task: nil, context: context, toast: toast)
        #expect(toast.message == "Only files can be uploaded. (2 of 3 uploaded)")
        #expect(project.files?.count == 2)
    }

    @Test func countsZeroWhenEveryFileInABatchFails() throws {
        let urls = [directory, directory.appending(path: "missing")]
        FileUpload.perform(urls, project: project, task: nil, context: context, toast: toast)
        #expect(toast.message?.hasSuffix("(0 of 2 uploaded)") == true)
        #expect(project.files?.isEmpty != false)
    }

    @Test func keepsTheSingleFileMessages() throws {
        FileUpload.perform([try write("a.png")], project: project, task: nil, context: context, toast: toast)
        #expect(toast.message == "Uploaded a.png")
    }
}
