import SwiftUI
import TychoCore
import TychoDesign

struct FilterValueList: View {
    let model: TaskViewModel
    let index: Int
    let options: [FilterOption]

    var body: some View {
        let selected = Set(model.state.filters.indices.contains(index) ? model.state.filters[index].values : [])
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                ForEach(options) { option in
                    row(option, isSelected: selected.contains(option.id))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.s3)
        }
        .frame(width: 220)
        .frame(maxHeight: 200)
        .accessibilityIdentifier("filter.values.\(index)")
    }

    private func row(_ option: FilterOption, isSelected: Bool) -> some View {
        Button {
            toggle(option.id)
        } label: {
            HStack(spacing: Spacing.s2) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.accentColor : Token.text3.color)
                Text(option.title)
                    .tychoFont(.sm)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("filter.value.\(option.id)")
    }

    private func toggle(_ id: String) {
        model.updateFilter(at: index) { filter in
            guard let position = filter.values.firstIndex(of: id) else {
                filter.values.append(id)
                return
            }
            filter.values.remove(at: position)
        }
    }
}

extension Binding where Value == Bool {
    static func open(_ openIndex: Binding<Int?>, at index: Int) -> Binding<Bool> {
        Binding(
            get: { openIndex.wrappedValue == index },
            set: { if !$0, openIndex.wrappedValue == index { openIndex.wrappedValue = nil } }
        )
    }
}
