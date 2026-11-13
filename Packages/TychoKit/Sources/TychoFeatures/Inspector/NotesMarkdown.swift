import CoreText
import Foundation
import SwiftUI

enum NotesMarkdown {
    static let codeFont = Font.body.monospaced()

    static func attributed(_ markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        var text = (try? AttributedString(markdown: markdown, options: options)) ?? AttributedString(markdown)
        let spans = text.runs[\.inlinePresentationIntent].compactMap { intent, range in
            intent.map { ($0, range) }
        }
        for (intent, range) in spans {
            text[range].inlinePresentationIntent = nil
            text[range].swiftUI.font = font(for: intent)
            if intent.contains(.strikethrough) {
                text[range].swiftUI.strikethroughStyle = .single
            }
        }
        return text
    }

    static func markdown(_ text: AttributedString, context: Font.Context) -> String {
        text.runs.map { run in
            NotesRunStyle(run, context: context).markdown(for: String(text[run.range].characters))
        }
        .joined()
    }

    fileprivate static func escaped(_ text: String) -> String {
        let characters = Array(text)
        return characters.indices.map { index in
            let character = characters[index]
            guard needsEscape(character, at: index, in: characters) else { return String(character) }
            return "\\\(character)"
        }
        .joined()
    }

    private static func needsEscape(_ character: Character, at index: Int, in characters: [Character]) -> Bool {
        guard character == "_" else { return "\\*`[]~".contains(character) }
        let before = index > characters.startIndex ? characters[index - 1] : " "
        let after = index + 1 < characters.endIndex ? characters[index + 1] : " "
        return !(before.isLetter || before.isNumber) || !(after.isLetter || after.isNumber)
    }

    private static func font(for intent: InlinePresentationIntent) -> Font? {
        guard !intent.contains(.code) else { return codeFont }
        switch (intent.contains(.stronglyEmphasized), intent.contains(.emphasized)) {
        case (true, true): return .body.bold().italic()
        case (true, false): return .body.bold()
        case (false, true): return .body.italic()
        case (false, false): return nil
        }
    }
}

private struct NotesRunStyle {
    var isBold = false
    var isItalic = false
    var isCode = false
    var isStruck = false
    var link: URL?

    init(_ run: AttributedString.Runs.Run, context: Font.Context) {
        if let font = run.swiftUI.font {
            let resolved = font.resolve(in: context)
            isBold = resolved.isBold
            isItalic = resolved.isItalic
            isCode =
                font == NotesMarkdown.codeFont
                || CTFontGetSymbolicTraits(resolved.ctFont).contains(.traitMonoSpace)
        }
        isStruck = run.swiftUI.strikethroughStyle != nil
        link = run.link
    }

    func markdown(for content: String) -> String {
        content.split(separator: "\n", omittingEmptySubsequences: false)
            .map { wrap(String($0)) }
            .joined(separator: "\n")
    }

    private func wrap(_ line: String) -> String {
        let core = line.trimmingCharacters(in: .whitespaces)
        guard !core.isEmpty else { return line }
        let leading = String(line.prefix { $0.isWhitespace })
        let trailing = String(line.reversed().prefix { $0.isWhitespace }.reversed())
        return leading + linked(struck(emphasized(core))) + trailing
    }

    private func emphasized(_ core: String) -> String {
        guard !isCode else { return "`\(core)`" }
        let marker = String(repeating: "*", count: (isItalic ? 1 : 0) + (isBold ? 2 : 0))
        return marker + NotesMarkdown.escaped(core) + marker
    }

    private func struck(_ body: String) -> String {
        isStruck ? "~~\(body)~~" : body
    }

    private func linked(_ body: String) -> String {
        guard let link else { return body }
        return "[\(body)](\(link.absoluteString))"
    }
}
