public enum FileName {
    public static func `extension`(of name: String) -> String {
        guard let dot = extensionDot(in: name) else { return "" }
        return name[name.index(after: dot)...].lowercased()
    }

    public static func duplicateName(of name: String) -> String {
        guard let dot = extensionDot(in: name) else { return "\(name) copy" }
        return "\(name[..<dot]) copy\(name[dot...])"
    }

    private static func extensionDot(in name: String) -> String.Index? {
        guard let dot = name.lastIndex(of: "."), dot != name.startIndex, name.index(after: dot) != name.endIndex
        else { return nil }
        return dot
    }
}
