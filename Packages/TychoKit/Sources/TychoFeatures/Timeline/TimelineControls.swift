import SwiftUI
import TychoCore
import TychoDesign

struct TimelineControls: View {
    @Environment(Router.self) private var router
    let showsNewTask: Bool
    let onToday: () -> Void

    var body: some View {
        @Bindable var router = router
        HStack(spacing: Spacing.s2) {
            Picker("Zoom", selection: $router.timelineZoom) {
                ForEach(TimelineZoom.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .accessibilityIdentifier("timeline.zoom")
            Picker("Group by", selection: $router.timelineGrouping) {
                ForEach(TimelineGrouping.allCases) { Text($0.title).tag($0) }
            }
            .labelsHidden()
            .fixedSize()
            .accessibilityIdentifier("timeline.group")
            Button("Today", systemImage: "scope", action: onToday)
                .buttonStyle(.borderless)
            Spacer()
            if showsNewTask {
                Button("New task", systemImage: "plus") { router.newTask() }
                    .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
    }
}
