import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

struct AttachmentsTests {
    @Test func cardsCaptionTheKindAndSize() {
        let file = FileRecord(name: "homepage-wireframes-v3.fig", byteCount: 4_404_019, uploadedAt: .now)
        #expect(AttachmentCard.caption(for: file) == "Figma · 4.2 MB")
    }
}
