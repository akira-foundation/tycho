import Foundation
import SwiftUI
import Testing

@testable import TychoFeatures

@MainActor
struct NotesMarkdownTests {
    private let context = EnvironmentValues().fontResolutionContext

    private func roundTrip(_ markdown: String) -> String {
        NotesMarkdown.markdown(NotesMarkdown.attributed(markdown), context: context)
    }

    @Test(arguments: [
        "Plain notes",
        "Ship **v2** with *care*, ~~not~~ `rush` and [docs](https://example.com).",
        "***Both*** at once",
        "- one\n- two\n\n1. first",
        "snake_case stays readable",
        "Line one\nLine **two**",
    ])
    func markdownSurvivesARoundTrip(markdown: String) {
        #expect(roundTrip(markdown) == markdown)
    }

    @Test func inlineMarkdownBecomesEditorAttributes() {
        let text = NotesMarkdown.attributed("a **b** *c* ~~d~~ `e` [f](https://example.com)")
        let runs = text.runs.map { (String(text[$0.range].characters), $0) }
        let bold = runs.first { $0.0 == "b" }?.1
        let strike = runs.first { $0.0 == "d" }?.1
        let link = runs.first { $0.0 == "f" }?.1
        #expect(bold?.font?.resolve(in: context).isBold == true)
        #expect(runs.first { $0.0 == "c" }?.1.font?.resolve(in: context).isItalic == true)
        #expect(strike?.strikethroughStyle != nil)
        #expect(link?.link == URL(string: "https://example.com"))
        #expect(runs.allSatisfy { $0.1.inlinePresentationIntent == nil })
    }

    @Test func formattingAppliedInTheEditorIsWrittenAsMarkdown() {
        var text = AttributedString("Make this bold please")
        let range = text.range(of: "bold")!
        text[range].font = Font.body.bold()
        #expect(NotesMarkdown.markdown(text, context: context) == "Make this **bold** please")
    }

    @Test func whitespaceStaysOutsideTheMarkers() {
        var text = AttributedString("a  spaced  b")
        let range = text.range(of: " spaced ")!
        text[range].font = Font.body.italic()
        #expect(NotesMarkdown.markdown(text, context: context) == "a  *spaced*  b")
    }

    @Test func literalMarkdownCharactersAreEscapedAndRestored() {
        let markdown = NotesMarkdown.markdown(AttributedString("2 * 3 = [six]"), context: context)
        #expect(markdown == #"2 \* 3 = \[six\]"#)
        #expect(String(NotesMarkdown.attributed(markdown).characters) == "2 * 3 = [six]")
    }
}
