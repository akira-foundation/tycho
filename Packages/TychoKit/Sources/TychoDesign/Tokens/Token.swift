import SwiftUI

public enum Token: String, CaseIterable, Sendable {
    case bg, bgSide, surface, surface2, surface3, sunken, overlay
    case border, borderStrong, divider
    case text, text2, text3, text4, textInv, onAccent
    case green, amber, red, blue, violet, teal, rose, orange, gray
    case stBacklog, stTodo, stProgress, stReview, stDone

    public var cssName: String {
        rawValue.replacing(/([A-Z0-9])/) { "-" + $0.output.1.lowercased() }
    }

    public var light: RGBA { pair.0 }
    public var dark: RGBA { pair.1 }
    public var color: Color { .dynamic(light: light, dark: dark) }

    public func soft(_ share: Double) -> Color { color.opacity(share) }

    private var pair: (RGBA, RGBA) {
        switch self {
        case .bg: (RGBA(hex: 0xFBFAF8), RGBA(hex: 0x1A1A19))
        case .bgSide: (RGBA(hex: 0xF4F3F0), RGBA(hex: 0x151514))
        case .surface: (RGBA(hex: 0xFFFFFF), RGBA(hex: 0x1D1D1C))
        case .surface2: (RGBA(hex: 0xF6F5F2), RGBA(hex: 0x252524))
        case .surface3: (RGBA(hex: 0xEEEDE9), RGBA(hex: 0x2D2D2B))
        case .sunken: (RGBA(hex: 0xF7F6F3), RGBA(hex: 0x181817))
        case .overlay: (RGBA(hex: 0x181613, alpha: 0.28), RGBA(hex: 0x000000, alpha: 0.55))
        case .border: (RGBA(hex: 0xE9E7E2), RGBA(hex: 0x2C2B29))
        case .borderStrong: (RGBA(hex: 0xDAD7D0), RGBA(hex: 0x3A3936))
        case .divider: (RGBA(hex: 0xF0EEEA), RGBA(hex: 0x252523))
        case .text: (RGBA(hex: 0x1D1C1A), RGBA(hex: 0xECEAE5))
        case .text2: (RGBA(hex: 0x57544E), RGBA(hex: 0xB5B2AB))
        case .text3: (RGBA(hex: 0x6B6760), RGBA(hex: 0x9A968F))
        case .text4: (RGBA(hex: 0x8C8880), RGBA(hex: 0x6F6C66))
        case .textInv: (RGBA(hex: 0xFFFFFF), RGBA(hex: 0x151514))
        case .onAccent: (RGBA(hex: 0xFFFFFF), RGBA(hex: 0x12131C))
        case .green: (RGBA(hex: 0x25754B), RGBA(hex: 0x5CBA86))
        case .amber: (RGBA(hex: 0x8F5E0E), RGBA(hex: 0xD8A443))
        case .red: (RGBA(hex: 0xB23C30), RGBA(hex: 0xE57D70))
        case .blue: (RGBA(hex: 0x3570C4), RGBA(hex: 0x72A5EA))
        case .violet: (RGBA(hex: 0x7652C2), RGBA(hex: 0xA98DEB))
        case .teal: (RGBA(hex: 0x1E8580), RGBA(hex: 0x58C0B6))
        case .rose: (RGBA(hex: 0xBC4270), RGBA(hex: 0xE68AAB))
        case .orange: (RGBA(hex: 0xC0612B), RGBA(hex: 0xE3925F))
        case .gray: (RGBA(hex: 0x8A867E), RGBA(hex: 0x8F8B84))
        case .stBacklog: (RGBA(hex: 0xA29E96), RGBA(hex: 0x6F6C66))
        case .stTodo: (RGBA(hex: 0x7C7870), RGBA(hex: 0xA6A39C))
        case .stProgress: (RGBA(hex: 0xC88A14), RGBA(hex: 0xD8A443))
        case .stReview: (RGBA(hex: 0x7652C2), RGBA(hex: 0xA98DEB))
        case .stDone: (RGBA(hex: 0x2E8456), RGBA(hex: 0x5CBA86))
        }
    }
}
