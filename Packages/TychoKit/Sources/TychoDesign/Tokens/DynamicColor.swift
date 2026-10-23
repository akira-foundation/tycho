import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public init(hex: UInt32, alpha: Double = 1) {
        let rgba = RGBA(hex: hex, alpha: alpha)
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }

    public static func dynamic(light: RGBA, dark: RGBA) -> Color {
        #if canImport(UIKit)
        Color(
            UIColor { traits in
                let value = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(red: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
            })
        #else
        Color(
            NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                let value = isDark ? dark : light
                return NSColor(srgbRed: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
            })
        #endif
    }
}
