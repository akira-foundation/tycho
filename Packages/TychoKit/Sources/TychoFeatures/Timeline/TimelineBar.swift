import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TimelineBar: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    let task: TaskItem
    let frame: BarFrame
    let start: Date
    let tint: Color
    let layout: TimelineLayout
    @GestureState private var drag: Double = 0

    static func showsTitleInside(width: Double) -> Bool { width > TimelineLayout.insideLabelWidth }

    var body: some View {
        let inside = Self.showsTitleInside(width: frame.width)
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Radius.sm).fill(tint.opacity(0.22))
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(tint.opacity(0.55))
                .frame(width: frame.width * Double(task.progress) / 100)
            if inside {
                HStack(spacing: Spacing.s1) {
                    if let assignee = task.assignee {
                        Avatar(initials: assignee.initials, color: assignee.tint, size: 16)
                    }
                    Text(task.title).lineLimit(1)
                }
                .padding(.horizontal, Spacing.s1)
            }
        }
        .tychoFont(.xxs, weight: .medium)
        .frame(width: frame.width, height: 22)
        .overlay(alignment: .leading) {
            if !inside {
                Text(task.title)
                    .tychoFont(.xxs)
                    .foregroundStyle(Token.text2.color)
                    .fixedSize()
                    .offset(x: frame.width + 8)
                    .allowsHitTesting(false)
            }
        }
        .opacity(task.status == .done ? 0.55 : 1)
        .offset(x: frame.x + Double(layout.dayOffset(forDrag: drag)) * layout.dayWidth)
        .help("\(task.title) · \(dateText.short(start)) → \(task.due.map(dateText.short) ?? "")")
        .onTapGesture { router.inspect(task.id) }
        .gesture(dragGesture)
        .contextMenu { TaskMenu(task: task) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("timeline.bar.\(task.key)")
    }

    private var barDrag: DragGesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named(TimelineCanvas.coordinateSpace))
    }

    #if os(iOS)
    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: barDrag)
            .updating($drag) { value, state, _ in
                if case .second(true, let drag?) = value { state = drag.translation.width }
            }
            .onEnded { value in
                if case .second(true, let drag?) = value { finish(drag.translation.width) }
            }
    }
    #else
    private var dragGesture: some Gesture {
        barDrag
            .updating($drag) { value, state, _ in state = value.translation.width }
            .onEnded { finish($0.translation.width) }
    }
    #endif

    private func finish(_ translation: Double) {
        let days = layout.dayOffset(forDrag: translation)
        var moved = false
        toast.perform { moved = try TaskActions(context: context).shift(task, byDays: days, calendar: layout.calendar) }
        if moved {
            toast.show(ScheduleMessages.moved(task.title, days: days))
        }
    }
}
