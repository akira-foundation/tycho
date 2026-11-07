import SwiftUI
import TychoCore

struct OptionalDateRow: View {
    @Environment(\.weekStart) private var weekStart
    let title: String
    let date: Date?
    let onChange: (Date?) -> Void

    var body: some View {
        LabeledContent(title) {
            if let date {
                HStack(spacing: 6) {
                    DatePicker(
                        title, selection: Binding(get: { date }, set: { onChange(DatePill.normalized($0)) }),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .environment(\.calendar, Calendar.picker(weekStart: weekStart))
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
