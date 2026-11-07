import SwiftUI
import TychoCore

struct TimelineZoomPicker: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        Picker("Zoom", selection: $router.timelineZoom) {
            ForEach(TimelineZoom.allCases) { Text($0.title).tag($0) }
        }
        .accessibilityIdentifier("timeline.zoom")
    }
}

struct TimelineGroupPicker: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        Picker("Group By", selection: $router.timelineGrouping) {
            ForEach(TimelineGrouping.allCases) { Text($0.title).tag($0) }
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("timeline.group")
    }
}

struct TimelineTodayButton: View {
    @Environment(Router.self) private var router

    var body: some View {
        Button("Today", systemImage: "calendar.badge.clock") { router.scrollTimelineToToday() }
            .accessibilityIdentifier("timeline.today")
    }
}

struct TimelineOptions: View {
    let showsZoom: Bool

    var body: some View {
        if showsZoom {
            TimelineZoomPicker().pickerStyle(.menu)
            TimelineTodayButton()
        }
        TimelineGroupPicker()
    }
}
