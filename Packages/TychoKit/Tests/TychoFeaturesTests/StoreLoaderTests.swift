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
}
