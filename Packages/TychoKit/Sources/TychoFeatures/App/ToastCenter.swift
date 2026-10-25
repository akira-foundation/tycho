import Foundation
import OSLog
import Observation
import TychoCore

extension ValidationError {
    public var userMessage: String {
        switch self {
        case .emptyTitle: "Title can't be empty."
        case .emptyName: "Name can't be empty."
        case .invalidProjectKey: "Key must be 2 to 5 letters."
        case .duplicateProjectKey: "That key is already in use."
        }
    }
}

@Observable
@MainActor
public final class ToastCenter {
    public private(set) var message: String?
    private var dismissal: Task<Void, Never>?
    private let logger = Logger(subsystem: "io.akira.tycho", category: "actions")

    public init() {}

    public func show(_ message: String) {
        self.message = message
        dismissal?.cancel()
        dismissal = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            self?.message = nil
        }
    }

    public func perform(_ work: () throws -> Void) {
        do {
            try work()
        } catch let error as ValidationError {
            show(error.userMessage)
        } catch {
            report(error)
        }
    }

    public func report(_ error: Error) {
        logger.error("Action failed: \(error.localizedDescription, privacy: .public)")
        show("Couldn't save changes.")
    }
}
