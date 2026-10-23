import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct TaskTransfer: Codable, Transferable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
