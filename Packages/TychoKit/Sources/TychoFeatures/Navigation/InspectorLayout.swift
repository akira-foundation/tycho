import CoreGraphics

enum InspectorLayout {
    static let minimumColumnWidth: CGFloat = 320
    static let idealColumnWidth: CGFloat = 380
    static let maximumColumnWidth: CGFloat = 520
    static let widestRouteMinimum: CGFloat = 570
    static let idealWidthsCountedInWindowMinimum: CGFloat = 2
    static let minimumWindowWidth = widestRouteMinimum + idealWidthsCountedInWindowMinimum * idealColumnWidth

    static func presentsAsSheet(windowWidth: CGFloat) -> Bool { windowWidth < minimumWindowWidth }
}
