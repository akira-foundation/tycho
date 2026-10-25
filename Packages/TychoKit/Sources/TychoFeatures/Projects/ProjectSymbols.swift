enum ProjectSymbols {
    static let all = [
        "folder", "globe", "iphone", "megaphone", "paperplane", "puzzlepiece", "building.2",
        "square.grid.2x2", "paintpalette", "hammer", "book", "chart.bar", "cart", "bolt",
        "leaf", "star", "heart", "flag", "camera", "music.note",
    ]

    static func suggestedKey(for name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace).map(String.init)
        let letterWords = words.filter { $0.first.map { $0.isASCII && $0.isLetter } ?? false }
        if words.count >= 2 {
            return String(letterWords.compactMap(\.first).prefix(5)).uppercased()
        }
        let letters = (words.first ?? "").filter { $0.isASCII && $0.isLetter }
        return String(letters.prefix(3)).uppercased()
    }
}
