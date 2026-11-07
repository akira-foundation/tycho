import SwiftUI
import TychoCore

struct OptionalDateRow: View {
    let title: String
    let date: Date?
    let onChange: (Date?) -> Void

    var body: some View {
        LabeledContent(title) {
            if let date {
                HStack(spacing: 6) {
                    CalendarField(title: title, selection: Binding(get: { date }, set: { onChange($0) }))
                    Button("Remove \(title)", systemImage: "xmark.circle.fill") { onChange(nil) }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("Add \(title)") { onChange(DatePill.normalized(.now)) }
                    .buttonStyle(.borderless)
            }
        }
    }
}
