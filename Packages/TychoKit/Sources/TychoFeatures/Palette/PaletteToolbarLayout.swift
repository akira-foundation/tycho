import CoreGraphics

enum PaletteToolbarLayout {
    static let labelWidth: CGFloat = 150
    static let minimumWindowWidthForLabel: CGFloat = 1400

    static func showsLabel(windowWidth: CGFloat) -> Bool { windowWidth >= minimumWindowWidthForLabel }
}
