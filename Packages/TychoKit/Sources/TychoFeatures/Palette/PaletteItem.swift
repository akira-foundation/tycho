import Foundation
import TychoCore

public enum PaletteItemKind: Equatable, Sendable {
    case command
    case task
    case project
    case file
    case recentSearch
    case suggestion
    case viewAll
}

public struct PaletteItem: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let trailing: String?
    public let visual: PaletteVisual?
    public let kind: PaletteItemKind
    public let action: PaletteAction

    public init(
        id: String, title: String, subtitle: String? = nil, trailing: String? = nil,
        visual: PaletteVisual? = nil, kind: PaletteItemKind, action: PaletteAction
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.visual = visual
        self.kind = kind
        self.action = action
    }

    public init(_ command: PaletteCommand) {
        self.init(
            id: command.id, title: command.title, trailing: command.hint,
            visual: .symbol(command.symbol), kind: .command, action: command.action)
    }
}

public struct PaletteSection: Identifiable {
    public let id: String
    public let title: String
    public let items: [PaletteItem]

    public init(id: String, title: String, items: [PaletteItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

public enum PaletteVisual: Equatable {
    case symbol(String)
    case status(TaskStatus)
    case project(symbol: String, color: ProjectColor)
    case file(FileKind)
}
