import SwiftUI
import TychoCore
import TychoDesign

struct FilterRow: View {
    let model: TaskViewModel
    let index: Int
    let filter: TaskFilter
    let members: [Member]
    let projects: [Project]
    @Binding var openIndex: Int?

    var body: some View {
        let options = FilterOptions.options(for: filter.field, members: members, projects: projects)
        HStack(spacing: Spacing.s2) {
            Text(index == 0 ? "Where" : "and")
                .tychoFont(.xs)
                .foregroundStyle(Token.text3.color)
                .frame(width: 44, alignment: .leading)
            Picker("Field", selection: fieldBinding) {
                ForEach(TaskFilterField.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .labelsHidden()
            .frame(width: 120)
            .accessibilityIdentifier("filter.field.\(index)")
            Picker("Operator", selection: operatorBinding) {
                ForEach(TaskFilterOperator.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .labelsHidden()
            .frame(width: 84)
            .accessibilityIdentifier("filter.op.\(index)")
            valuesButton(options: options)
            Spacer(minLength: 0)
            Button("Remove filter", systemImage: "xmark") { model.removeFilter(at: index) }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .accessibilityIdentifier("filter.remove.\(index)")
        }
    }

    private func valuesButton(options: [FilterOption]) -> some View {
        let summary = FilterOptions.summary(filter, options: options)
        return Button {
            openIndex = index
        } label: {
            Text(filter.values.isEmpty ? "Select…" : summary)
                .lineLimit(1)
                .frame(maxWidth: 160, alignment: .leading)
        }
        .buttonStyle(.tycho(.secondary, size: .sm))
        .popover(
            isPresented: Binding(
                get: { openIndex == index },
                set: { if !$0, openIndex == index { openIndex = nil } }
            )
        ) {
            FilterValueList(model: model, index: index, options: options)
        }
        .accessibilityIdentifier("filter.values.button.\(index)")
    }

    private var fieldBinding: Binding<TaskFilterField> {
        Binding(
            get: { filter.field },
            set: { field in
                guard field != filter.field else { return }
                model.updateFilter(at: index) {
                    $0.field = field
                    $0.values = []
                }
                openIndex = index
            }
        )
    }

    private var operatorBinding: Binding<TaskFilterOperator> {
        Binding(
            get: { filter.op },
            set: { op in model.updateFilter(at: index) { $0.op = op } }
        )
    }
}
