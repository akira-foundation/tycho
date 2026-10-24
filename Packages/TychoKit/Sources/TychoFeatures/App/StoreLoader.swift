import Foundation
import OSLog
import Observation
import SwiftData
import TychoCore

@Observable
@MainActor
public final class StoreLoader {
    public enum State {
        case loading
        case ready(ModelContainer)
        case failed(String)
    }

    public private(set) var state: State = .loading
    private let factory: () throws -> ModelContainer
    private let resetStore: () throws -> Void
    private let logger = Logger(subsystem: "io.akira.tycho", category: "store")

    public init(factory: @escaping () throws -> ModelContainer, resetStore: @escaping () throws -> Void) {
        self.factory = factory
        self.resetStore = resetStore
    }

    public static func usesMemory(arguments: [String]) -> Bool { arguments.contains("-uiTesting") }

    public static func live(arguments: [String] = ProcessInfo.processInfo.arguments) -> StoreLoader {
        let inMemory = usesMemory(arguments: arguments)
        return StoreLoader(
            factory: { try TychoSchema.makeContainer(inMemory: inMemory) },
            resetStore: { try removeStoreFiles(at: TychoSchema.storeURL) }
        )
    }

    static func removeStoreFiles(at storeURL: URL, fileManager: FileManager = .default) throws {
        let directory = storeURL.deletingLastPathComponent()
        for suffix in ["", "-shm", "-wal"] {
            let file = directory.appending(path: storeURL.lastPathComponent + suffix)
            if fileManager.fileExists(atPath: file.path(percentEncoded: false)) {
                try fileManager.removeItem(at: file)
            }
        }
    }

    public func load() {
        FileQuickLook.sweep()
        do {
            state = .ready(try factory())
        } catch {
            logger.error("Store failed to open: \(error.localizedDescription, privacy: .public)")
            state = .failed(error.localizedDescription)
        }
    }

    public func resetAndReload() {
        do {
            try resetStore()
        } catch {
            logger.error("Store reset failed: \(error.localizedDescription, privacy: .public)")
            state = .failed("Couldn't reset data: \(error.localizedDescription)")
            return
        }
        load()
    }
}
