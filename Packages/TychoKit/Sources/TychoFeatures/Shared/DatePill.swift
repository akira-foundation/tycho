import SwiftUI
import TychoCore
import TychoDesign

struct DatePill: View {
    @Environment(\.dateText) private var dateText
    let date: Date?
    let emptyText: String
    var color: Color = .primary
    let onChange: (Date?) -> Void
    @State private var picking = false
    @State private var draft = Date.now
    @State private var edited = false

    static func normalized(_ value: Date) -> Date {
        DayTime.noon(of: value, calendar: DateText.gregorian)
    }

    static func dateToCommit(stored: Date?, draft: Date, edited: Bool) -> Date? {
        guard edited else { return nil }
        let candidate = normalized(draft)
        return candidate == stored ? nil : candidate
    }

    var body: some View {
        Button {
            draft = date ?? .now
            edited = false
            picking = true
        } label: {
            Text(date.map(dateText.short) ?? emptyText)
                .monospacedDigit()
                .foregroundStyle(date == nil ? AnyShapeStyle(.tertiary) : AnyShapeStyle(color))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .themedPopover(isPresented: $picking) { picker }
        .onChange(of: picking) { _, isPicking in
            if !isPicking { commitDraft() }
        }
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                "Date",
                selection: Binding(
                    get: { draft },
                    set: {
                        draft = $0
                        edited = true
                    }),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            HStack {
                Button("Today") {
                    draft = .now
                    edited = true
                    picking = false
                }
                .buttonStyle(.bordered)
                Spacer()
                if date != nil {
                    Button("Clear Date", role: .destructive) {
                        edited = false
                        picking = false
                        onChange(nil)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }

    private func commitDraft() {
        guard let value = Self.dateToCommit(stored: date, draft: draft, edited: edited) else { return }
        edited = false
        onChange(value)
    }
}
