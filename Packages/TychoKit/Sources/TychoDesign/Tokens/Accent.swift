import SwiftUI

public enum Accent: String, CaseIterable, Sendable, Identifiable {
    case indigo, blue, violet, teal, rose, graphite

    public var id: String { rawValue }
    public var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    public var light: RGBA {
        switch self {
        case .indigo: RGBA(hex: 0x4B5BD6)
        case .blue: RGBA(hex: 0x2F6CD4)
        case .violet: RGBA(hex: 0x7348CC)
        case .teal: RGBA(hex: 0x1A7F7A)
        case .rose: RGBA(hex: 0xB93D68)
        case .graphite: RGBA(hex: 0x34332F)
        }
    }

    public var dark: RGBA {
        switch self {
        case .indigo: RGBA(hex: 0x8E9AF3)
        case .blue: RGBA(hex: 0x74A7F0)
        case .violet: RGBA(hex: 0xAE93F0)
        case .teal: RGBA(hex: 0x5CC4BA)
        case .rose: RGBA(hex: 0xEC8DAE)
        case .graphite: RGBA(hex: 0xD9D6CF)
        }
    }

    public var color: Color { .dynamic(light: light, dark: dark) }
    public var soft: Color { color.opacity(0.10) }
    public var line: Color { color.opacity(0.38) }
}
