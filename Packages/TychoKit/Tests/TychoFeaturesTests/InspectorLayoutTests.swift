#if os(macOS)
import AppKit
import SwiftData
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct InspectorLayoutTests {
    enum Destination: String, CaseIterable, Sendable {
        case home, myTasks, tasks, calendar, timeline, projects
        case board, list, table, projectCalendar, projectTimeline, files
    }

    @MainActor private struct DemoFixture {
        let container: ModelContainer
        let task: TaskItem

        init() throws {
            container = try TychoSchema.makeContainer(inMemory: true)
            _ = try DemoSeed.load(into: container.mainContext, now: .now, calendar: .current)
            let tasks = try container.mainContext.fetch(FetchDescriptor<TaskItem>())
            task = try #require(tasks.first { $0.key == "DS-109" })
        }

        func route(_ destination: Destination) throws -> AppRoute {
            let project = try #require(task.project).id
            return switch destination {
            case .home: .home
            case .myTasks: .myTasks
            case .tasks: .tasks
            case .calendar: .calendar
            case .timeline: .timeline
            case .projects: .projects
            case .board: .project(project, .board)
            case .list: .project(project, .list)
            case .table: .project(project, .table)
            case .projectCalendar: .project(project, .calendar)
            case .projectTimeline: .project(project, .timeline)
            case .files: .project(project, .files)
            }
        }

        func minimumWindowWidth(
            at width: CGFloat, showing destination: Destination, inspecting: Bool
        ) throws
            -> CGFloat
        {
            let router = Router()
            router.open(try route(destination))
            router.windowWidth = width
            if inspecting { router.inspect(task.id) }
            let host = NSHostingController(
                rootView: RootView().environment(router).environment(ToastCenter()).modelContainer(container))
            let window = NSWindow(contentViewController: host)
            window.setContentSize(NSSize(width: width, height: 800))
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            return window.contentMinSize.width
        }
    }

    @Test(arguments: Destination.allCases)
    func narrowWindowKeepsItsWidthWithTheInspectorOpen(destination: Destination) throws {
        let fixture = try DemoFixture()

        let minimum = try fixture.minimumWindowWidth(at: 900, showing: destination, inspecting: true)

        #expect(minimum <= 900)
    }

    @Test(arguments: Destination.allCases)
    func inspectorColumnFitsAtTheThreshold(destination: Destination) throws {
        let fixture = try DemoFixture()
        let threshold = InspectorLayout.minimumWindowWidth

        let closed = try fixture.minimumWindowWidth(at: threshold, showing: destination, inspecting: false)
        let open = try fixture.minimumWindowWidth(at: threshold, showing: destination, inspecting: true)

        #expect(open > closed)
        #expect(open <= threshold)
    }

    @Test func routerPresentsTheInspectorAsASheetBelowTheThreshold() {
        let router = Router()
        #expect(!router.inspectsInSheet)
        router.windowWidth = InspectorLayout.minimumWindowWidth - 1
        #expect(router.inspectsInSheet)
        router.windowWidth = InspectorLayout.minimumWindowWidth
        #expect(!router.inspectsInSheet)
    }

    @Test func crossingTheThresholdKeepsTheSameTaskInExactlyOnePresentation() {
        let router = Router()
        let id = UUID()
        router.windowWidth = InspectorLayout.minimumWindowWidth
        router.inspect(id)
        #expect(router.isInspectorColumnPresented)
        #expect(!router.isInspectorSheetPresented)

        router.windowWidth = 900
        #expect(router.inspectedTaskID == id)
        #expect(router.isInspectorSheetPresented)
        #expect(!router.isInspectorColumnPresented)

        router.windowWidth = InspectorLayout.minimumWindowWidth
        #expect(router.inspectedTaskID == id)
        #expect(router.isInspectorColumnPresented)

        router.closeInspector()
        #expect(!router.isInspectorColumnPresented)
        #expect(!router.isInspectorSheetPresented)
    }
}
#endif
