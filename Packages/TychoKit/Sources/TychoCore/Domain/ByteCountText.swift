import Foundation

public enum ByteCountText {
    public static func format(_ bytes: Int) -> String {
        switch bytes {
        case ..<1024: "\(bytes) B"
        case ..<1_048_576: "\(Int((Double(bytes) / 1024).rounded())) KB"
        default: String(format: "%.1f MB", Double(bytes) / 1_048_576)
        }
    }
}
