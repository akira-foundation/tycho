import SwiftUI
import TychoCore

struct FilterForm: View {
    let engine: TaskViewEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let model = engine.model
        let filters = model.state.filters
        NavigationStack {
            Form {
                if filters.isEmpty {
                    Text(
                        "Combine filters to narrow the task list, for example Status is In Progress and Assignee is Sarah."
                    )
                    .foregroundStyle(.secondary)
                }
                ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                    FilterSection(engine: engine, index: index, filter: filter)
                }
                Section {
                    Menu("Add Filter", systemImage: "plus") {
                        ForEach(TaskFilterField.allCases, id: \.self) { field in
                            Button(field.title, systemImage: field.symbol) { model.addFilter(field) }
                                .accessibilityIdentifier("filter.add.\(field.rawValue)")
                        }
                    }
                    .accessibilityIdentifier("filter.add")
                    if !filters.isEmpty {
                        Button("Clear All Filters", role: .destructive) { model.clearFilters() }
                            .accessibilityIdentifier("filter.clear")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Filter")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { dismiss() }
                    .accessibilityIdentifier("filter.done")
                }
            }
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 420, idealWidth: 460, minHeight: 320, idealHeight: 420)
        #else
        .presentationDetents([.medium, .large])
        #endif
        .accessibilityIdentifier("filter.builder")
    }
}

struct FilterSection: View {
    let engine: TaskViewEngine
    let index: Int
    let filter: TaskFilter

    var body: some View {
        let model = engine.model
        let options = FilterOptions.options(for: filter.field, members: engine.members, projects: engine.projects)
        Section(index == 0 ? "Where" : "And") {
            Picker("Field", selection: field) {
                ForEach(TaskFilterField.allCases, id: \.self) { Label($0.title, systemImage: $0.symbol).tag($0) }
            }
            .accessibilityIdentifier("filter.field.\(index)")
            Picker("Condition", selection: condition) {
                ForEach(TaskFilterOperator.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .accessibilityIdentifier("filter.op.\(index)")
            LabeledContent("Values") {
                #if os(macOS)
                VStack(alignment: .leading) { toggles(options) }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("filter.values.\(index)")
                #else
                Menu(FilterOptions.summary(filter, options: options)) { toggles(options) }
                    .menuActionDismissBehavior(.disabled)
                    .accessibilityIdentifier("filter.values.button.\(index)")
                #endif
            }
            Button("Remove Filter", role: .destructive) { model.removeFilter(at: index) }
                .accessibilityIdentifier("filter.remove.\(index)")
        }
    }

    private var field: Binding<TaskFilterField> {
        Binding(get: { filter.field }, set: { engine.model.setField(at: index, to: $0) })
    }

    private var condition: Binding<TaskFilterOperator> {
        Binding(get: { filter.op }, set: { op in engine.model.updateFilter(at: index) { $0.op = op } })
    }

    private func toggles(_ options: [FilterOption]) -> some View {
        ForEach(options) { option in
            Toggle(option.title, isOn: isSelected(option))
                .accessibilityIdentifier("filter.value.\(option.id)")
        }
    }

    private func isSelected(_ option: FilterOption) -> Binding<Bool> {
        Binding(
            get: { filter.values.contains(option.id) },
            set: { _ in engine.model.toggleValue(option.id, inFilterAt: index) })
    }
}
