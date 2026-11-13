import SwiftUI
import TychoCore

protocol TaskViewMode: RawRepresentable, CaseIterable, Identifiable, Hashable
where RawValue == String, AllCases == [Self] {
    static var fallback: Self { get }
    var layout: ProjectBuiltInTab { get }
}

extension TaskViewMode {
    init(state: TaskViewState) {
        self = state.mode.flatMap(Self.init(rawValue:)) ?? .fallback
    }

    var id: String { rawValue }
    var title: String { layout.title }
    var symbol: String { layout.symbol }
}

struct TaskModePicker<Mode: TaskViewMode>: View {
    let model: TaskViewModel
    let mode: Mode
    let identifier: String

    var body: some View {
        Picker(selection: Binding(get: { mode }, set: { model.state.mode = $0.rawValue })) {
            ForEach(Mode.allCases) { SegmentLabel(title: $0.title, symbol: $0.symbol).tag($0) }
        } label: {
            Label("View", systemImage: mode.symbol)
        }
        .accessibilityIdentifier(identifier)
    }

    func segmentedToolbar() -> some View {
        pickerStyle(.segmented).segmentedToolbarWidth(Mode.allCases.count)
    }
}

extension View {
    @ViewBuilder fileprivate func segmentedToolbarWidth(_ segments: Int) -> some View {
        #if os(iOS)
        self.frame(width: CGFloat(segments) * 44)
        #else
        self
        #endif
    }
}
