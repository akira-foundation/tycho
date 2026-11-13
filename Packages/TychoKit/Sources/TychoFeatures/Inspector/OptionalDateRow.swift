import SwiftUI
import TychoCore

struct OptionalDateRow: View {
    let title: String
    let date: Date?
    let onChange: (Date?) -> Void

    var isOn: Binding<Bool> {
        Binding(
            get: { date != nil },
            set: { onChange($0 ? DatePill.normalized(.now) : nil) })
    }

    var body: some View {
        Toggle("\(title) Date", isOn: isOn)
        if let date {
            DatePicker(
                title,
                selection: Binding(get: { date }, set: { onChange(DatePill.normalized($0)) }),
                displayedComponents: .date
            )
        }
    }
}
