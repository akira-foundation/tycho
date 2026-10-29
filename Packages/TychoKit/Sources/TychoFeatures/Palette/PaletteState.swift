import TychoCore

public enum PaletteMode: Equatable, Sendable {
    case commands
    case search
}

public struct PaletteState: Equatable {
    public var mode: PaletteMode
    public var query: String = ""
    public var scope: SearchScope = .all
    public var highlight: Int = 0

    public init(mode: PaletteMode) {
        self.mode = mode
    }
}
