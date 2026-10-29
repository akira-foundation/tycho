import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct BrokenStore: Error {}

@MainActor
struct StoreLoaderTests {
    @Test func loadsAContainer() {
        let loader = StoreLoader(factory: { try TychoSchema.makeContainer(inMemory: true) }, resetStore: {})
        loader.load()
        guard case .ready = loader.state else {
            Issue.record("expected ready, got \(loader.state)")
            return
        }
    }

    @Test func reportsFailureAndRecoversAfterReset() {
        var broken = true
        var resets = 0
        let loader = StoreLoader(
            factory: {
                if broken { throw BrokenStore() }
                return try TychoSchema.makeContainer(inMemory: true)
            },
            resetStore: {
                resets += 1
                broken = false
            }
        )
        loader.load()
        guard case .failed = loader.state else {
            Issue.record("expected failed, got \(loader.state)")
            return
        }
        loader.resetAndReload()
        #expect(resets == 1)
        guard case .ready = loader.state else {
            Issue.record("expected ready after reset, got \(loader.state)")
            return
        }
    }

    @Test func uiTestingArgumentSelectsAnInMemoryStore() {
        #expect(StoreLoader.usesMemory(arguments: ["Tycho", "-uiTesting"]))
        #expect(!StoreLoader.usesMemory(arguments: ["Tycho"]))
    }

    @Test func validationErrorsHaveUserMessages() {
        #expect(ValidationError.emptyTitle.userMessage == "Title can't be empty.")
        #expect(ValidationError.invalidProjectKey.userMessage == "Key must be 2 to 5 letters.")
        #expect(ValidationError.duplicateProjectKey.userMessage == "That key is already in use.")
        #expect(ValidationError.emptyName.userMessage == "Name can't be empty.")
    }

    @Test func toastPerformShowsTheValidationMessage() {
        let toast = ToastCenter()
        toast.perform { throw ValidationError.emptyTitle }
        #expect(toast.message == "Title can't be empty.")
    }

    @Test func resetFailureIsReportedAndSkipsReload() {
        var loads = 0
        let loader = StoreLoader(
            factory: {
                loads += 1
                return try TychoSchema.makeContainer(inMemory: true)
            },
            resetStore: { throw BrokenStore() }
        )
        loader.resetAndReload()
        guard case .failed(let message) = loader.state else {
            Issue.record("expected failed, got \(loader.state)")
            return
        }
        #expect(message.hasPrefix("Couldn't reset data"))
        #expect(loads == 0)
    }

    @Test func removeStoreFilesDeletesFilesInDirectoriesWithSpaces() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "Application Support \(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "Tycho.store")
        let names = ["Tycho.store", "Tycho.store-shm", "Tycho.store-wal"]
        for name in names {
            try Data("x".utf8).write(to: directory.appending(path: name))
        }

        try StoreLoader.removeStoreFiles(at: storeURL)

        for name in names {
            let path = directory.appending(path: name).path(percentEncoded: false)
            #expect(!FileManager.default.fileExists(atPath: path))
        }
    }

    @Test func removeStoreFilesAlsoDeletesTheSupportDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let support = directory.appending(path: ".Tycho_SUPPORT").appending(path: "_EXTERNAL_DATA")
        try FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data("x".utf8).write(to: support.appending(path: "blob"))
        try Data("x".utf8).write(to: directory.appending(path: "Other.store"))

        try StoreLoader.removeStoreFiles(at: directory.appending(path: "Tycho.store"))

        let remaining = try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false))
        #expect(remaining == ["Other.store"])
    }

    @Test func resetRemovesEverythingASwiftDataStoreWithExternalBlobsCreates() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "Tycho.store")
        do {
            let configuration = ModelConfiguration(
                "Tycho", schema: Schema(TychoSchema.models), url: storeURL, cloudKitDatabase: .none)
            let container = try ModelContainer(for: Schema(TychoSchema.models), configurations: configuration)
            let record = FileRecord(name: "big.bin", byteCount: 400_000, uploadedAt: .now)
            record.data = Data(repeating: 7, count: 400_000)
            record.hasData = true
            container.mainContext.insert(record)
            try container.mainContext.save()
        }
        let created = try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false))
        #expect(created.contains { $0.hasSuffix("_SUPPORT") })

        try StoreLoader.removeStoreFiles(at: storeURL)

        let remaining = try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false))
        #expect(remaining.isEmpty)
    }
}
