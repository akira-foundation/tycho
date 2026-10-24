import Foundation

public enum ByteCountText {
    public static func format(_ bytes: Int) -> String {
        switch bytes {
        case ..<1024: "\(bytes) B"
        case ..<1_048_576: "\(Int((Double(bytes) / 1024).rounded())) KB"
        default: megabytes(bytes)
        }
    }

    private static func megabytes(_ bytes: Int) -> String {
        let text = String(format: "%.1f", Double(bytes) / 1_048_576)
        return (text.hasSuffix(".0") ? String(text.dropLast(2)) : text) + " MB"
    }
}
