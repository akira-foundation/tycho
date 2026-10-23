import Foundation
import SwiftData

@MainActor
public enum EmptySeed {
    @discardableResult
    public static func load(into context: ModelContext, ownerName: String) throws -> Workspace {
        let name = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw ValidationError.emptyName }
        let workspace = Workspace(name: "Personal")
        context.insert(workspace)
        let me = Member(name: name, email: "", colorHex: ProjectColor.indigo.hex, role: .owner, isMe: true)
        context.insert(me)
        me.workspace = workspace
        try context.saveOrRollback()
        return workspace
    }
}
