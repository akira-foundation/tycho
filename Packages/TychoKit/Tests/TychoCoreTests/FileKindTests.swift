import Testing

@testable import TychoCore

struct FileKindTests {
    @Test(arguments: [
        ("homepage.fig", FileKind.fig), ("brief.PDF", .pdf), ("photos.rar", .zip), ("set.7z", .zip),
        ("hero.png", .img), ("Photo.HEIC", .img), ("vector.svg", .img), ("budget.numbers", .sheet),
        ("data.csv", .sheet), ("notes.md", .doc), ("letter.pages", .doc), ("app.ts", .code),
        ("events.json", .code), ("archive.tar.gz", .other), ("README", .other), ("movie.mov", .other),
    ])
    func mapsTheExtension(name: String, kind: FileKind) {
        #expect(FileKind.from(fileName: name) == kind)
    }

    @Test func namesAndColorsMatchTheOriginal() {
        #expect(
            FileKind.allCases.map(\.title) == [
                "Figma", "PDF", "Archive", "Image", "Spreadsheet", "Document", "Code", "File",
            ])
        #expect(
            FileKind.allCases.map(\.hex) == [
                0x8662C9, 0xC4473A, 0x6B7280, 0x23918A, 0x3D8E5F, 0x3B82C4, 0xC48A1E, 0x6B7280,
            ])
    }

    @Test func extensionsAreLowercasedAndOptional() {
        #expect(FileName.extension(of: "Photo.HEIC") == "heic")
        #expect(FileName.extension(of: "archive.tar.gz") == "gz")
        #expect(FileName.extension(of: "README") == "")
        #expect(FileName.extension(of: ".gitignore") == "")
        #expect(FileName.extension(of: "draft.") == "")
    }

    @Test func duplicateNamesKeepTheExtension() {
        #expect(FileName.duplicateName(of: "sitemap-v2.pdf") == "sitemap-v2 copy.pdf")
        #expect(FileName.duplicateName(of: "archive.tar.gz") == "archive.tar copy.gz")
        #expect(FileName.duplicateName(of: "README") == "README copy")
    }

    @Test(arguments: [
        (0, "0 B"), (1023, "1023 B"), (1024, "1 KB"), (880_640, "860 KB"), (1_048_575, "1024 KB"),
        (1_048_576, "1.0 MB"), (4_404_019, "4.2 MB"), (134_217_728, "128.0 MB"),
    ])
    func formatsSizesLikeTheOriginal(bytes: Int, text: String) {
        #expect(ByteCountText.format(bytes) == text)
    }
}
