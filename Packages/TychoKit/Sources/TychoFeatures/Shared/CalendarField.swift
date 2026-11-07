import SwiftUI
import TychoCore

struct CalendarPicker: View {
    @Environment(\.weekStart) private var weekStart
    let title: String
    @Binding var selection: Date

    var body: some View {
        #if os(macOS)
        MonthPicker(selection: $selection)
        #else
        DatePicker(title, selection: $selection, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .environment(\.calendar, Calendar.picker(weekStart: weekStart))
        #endif
    }
}

struct CalendarField: View {
    @Environment(\.dateText) private var dateText
    @Environment(\.weekStart) private var weekStart
    let title: String
    @Binding var selection: Date
    @State private var isPicking: Bool

    init(title: String, selection: Binding<Date>, isPicking: Bool = false) {
        self.title = title
        _selection = selection
        _isPicking = State(initialValue: isPicking)
    }

    var body: some View {
        #if os(macOS)
        Button {
            isPicking = true
        } label: {
            Label(dateText.long(selection), systemImage: "calendar")
                .monospacedDigit()
        }
        .accessibilityLabel(title)
        .accessibilityValue(dateText.long(selection))
        .popover(isPresented: $isPicking, arrowEdge: .bottom) {
            CalendarPicker(title: title, selection: pickedSelection)
                .padding()
                .presentationBackground(.background)
        }
        #else
        DatePicker(title, selection: normalizedSelection, displayedComponents: .date)
            .labelsHidden()
            .environment(\.calendar, Calendar.picker(weekStart: weekStart))
        #endif
    }

    var pickedSelection: Binding<Date> {
        Binding(
            get: { selection },
            set: {
                normalizedSelection.wrappedValue = $0
                isPicking = false
            })
    }

    var normalizedSelection: Binding<Date> {
        Binding(get: { selection }, set: { selection = DatePill.normalized($0) })
    }
}
