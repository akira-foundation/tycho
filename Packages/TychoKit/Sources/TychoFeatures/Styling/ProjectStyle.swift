import SwiftUI
import TychoCore
import TychoDesign

extension ProjectStatus {
    public var token: Token {
        switch self {
        case .planning: .gray
        case .active: .blue
        case .risk: .red
        case .hold: .amber
        case .complete: .green
        }
    }

    public var tint: Color { token.color }
}

extension ProjectColor {
    public var tint: Color { Color(hex: hex) }
}

extension Member {
    public var tint: Color { Color(hex: colorHex) }
}
