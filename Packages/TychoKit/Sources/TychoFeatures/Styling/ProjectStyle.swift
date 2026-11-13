import SwiftUI
import TychoCore
import TychoDesign

extension ProjectStatus {
    public var symbol: String {
        switch self {
        case .planning: "circle.dashed"
        case .active: "circle.lefthalf.filled"
        case .risk: "exclamationmark.triangle.fill"
        case .hold: "pause.circle.fill"
        case .complete: "checkmark.circle.fill"
        }
    }

    public var tint: Color {
        switch self {
        case .planning: .gray
        case .active: .blue
        case .risk: .red
        case .hold: .orange
        case .complete: .green
        }
    }
}

extension ProjectColor {
    public var tint: Color { Color(hex: hex) }
}

extension Member {
    public var tint: Color { Color(hex: colorHex) }
}
