public enum FileKind: String, CaseIterable, Codable, Sendable, Identifiable {
    case fig
    case pdf
    case zip
    case img
    case sheet
    case doc
    case code
    case other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .fig: "Figma"
        case .pdf: "PDF"
        case .zip: "Archive"
        case .img: "Image"
        case .sheet: "Spreadsheet"
        case .doc: "Document"
        case .code: "Code"
        case .other: "File"
        }
    }

    public var hex: UInt32 {
        switch self {
        case .fig: 0x8662C9
        case .pdf: 0xC4473A
        case .zip, .other: 0x6B7280
        case .img: 0x23918A
        case .sheet: 0x3D8E5F
        case .doc: 0x3B82C4
        case .code: 0xC48A1E
        }
    }

    public static func from(fileName: String) -> FileKind {
        switch FileName.extension(of: fileName) {
        case "fig": .fig
        case "pdf": .pdf
        case "zip", "rar", "7z": .zip
        case "png", "jpg", "jpeg", "gif", "webp", "svg", "heic": .img
        case "xlsx", "xls", "csv", "numbers": .sheet
        case "doc", "docx", "txt", "md", "pages", "rtf": .doc
        case "js", "ts", "json", "html", "css", "py": .code
        default: .other
        }
    }
}
