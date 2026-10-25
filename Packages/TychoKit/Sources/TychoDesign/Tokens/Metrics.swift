import CoreGraphics

public enum Radius {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 6
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 10
    public static let full: CGFloat = 999
}

public struct Metrics: Equatable, Sendable {
    public let rowHeight: CGFloat
    public let cardPadding: CGFloat
    public let sideRow: CGFloat

    public init(rowHeight: CGFloat, cardPadding: CGFloat, sideRow: CGFloat) {
        self.rowHeight = rowHeight
        self.cardPadding = cardPadding
        self.sideRow = sideRow
    }
}

public enum Density: String, CaseIterable, Sendable, Identifiable {
    case comfortable, compact

    public var id: String { rawValue }
    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    public var metrics: Metrics {
        switch self {
        case .comfortable: Metrics(rowHeight: 40, cardPadding: 10, sideRow: 30)
        case .compact: Metrics(rowHeight: 34, cardPadding: 8, sideRow: 26)
        }
    }
}
