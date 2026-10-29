#if os(macOS)
import AppKit
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct InspectorTitleEditTests {
    @Test func titleRenamedInTheSheetSurvivesClosingIt() throws {
        let fixture = try InspectorHostFixture(width: 1000)

        try fixture.renameInSheet(to: "Renamed in sheet", submit: true)
        fixture.router.closeInspector()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Renamed in sheet")
        fixture.window.orderOut(nil)
    }

    @Test func titleRenamedInTheSheetSurvivesWideningAndClosingTheColumn() throws {
        let fixture = try InspectorHostFixture(width: 1000)

        try fixture.renameInSheet(to: "Renamed in sheet", submit: true)
        fixture.resize(to: 1500)
        fixture.router.closeInspector()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Renamed in sheet")
        fixture.window.orderOut(nil)
    }

    @Test func columnIsNotBuiltWhileTheInspectorIsASheet() throws {
        let fixture = try InspectorHostFixture(width: 1000)

        let columnFields = fixture.editableFields(in: fixture.window)

        #expect(!columnFields.contains { $0.stringValue == fixture.task.title })
        #expect(fixture.router.liveInspectorFlushCount == 3)
        fixture.window.orderOut(nil)
    }

    @Test func columnShowsATitleRenamedElsewhere() throws {
        let fixture = try InspectorHostFixture(width: 1500)

        try TaskActions(context: fixture.container.mainContext).rename(fixture.task, to: "Renamed elsewhere")
        fixture.settle(0.6)

        let field = try fixture.titleField(in: fixture.window, current: "Renamed elsewhere")
        #expect(field.stringValue == "Renamed elsewhere")
        fixture.window.orderOut(nil)
    }

    @Test func columnShowsAnEstimateChangedElsewhere() throws {
        let fixture = try InspectorHostFixture(width: 1500)

        try TaskActions(context: fixture.container.mainContext).edit(fixture.task) { $0.estimate = "5d" }
        fixture.settle(0.6)

        let field = try fixture.estimateField(in: fixture.window)
        #expect(field.stringValue == "5d")
        fixture.window.orderOut(nil)
    }
}
#endif
