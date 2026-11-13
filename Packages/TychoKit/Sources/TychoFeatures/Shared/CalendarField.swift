import SwiftUI

struct CalendarField: View {
    let title: String
    @Binding var selection: Date

    var body: some View {
        DatePicker(title, selection: normalizedSelection, displayedComponents: .date)
            .labelsHidden()
    }

    var normalizedSelection: Binding<Date> {
        Binding(get: { selection }, set: { selection = DatePill.normalized($0) })
    }
}
