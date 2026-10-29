import SwiftUI
import TychoCore
import TychoDesign

extension FileKind {
    public var symbol: String {
        switch self {
        case .fig: "pencil.tip.crop.circle"
        case .pdf: "doc.richtext"
        case .zip: "archivebox"
        case .img: "photo"
        case .sheet: "tablecells"
        case .doc: "doc.text"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .other: "doc"
        }
    }

    public var tint: Color { Color(hex: hex) }
}
