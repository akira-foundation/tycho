import SwiftUI
import TychoCore

struct FilterForm: View {
    let engine: TaskViewEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 0) {
            Text("Filter")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("filter.title")
                .padding([.horizontal, .top])
            form
                .frame(maxHeight: 640)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 440)
        .accessibilityIdentifier("filter.builder")
        #else
        NavigationStack {
            form
                .navigationTitle("Filter")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) { dismiss() }
                            .accessibilityIdentifier("filter.done")
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .accessibilityIdentifier("filter.builder")
        #endif
    }

    private var form: some View {
        let model = engine.model
        let filters = model.state.filters
        return Form {
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
    }
}

struct FilterSection: View {
    let engine: TaskViewEngine
    let index: Int
    let filter: TaskFilter

    var body: some View {
        let options = FilterOptions.options(for: filter.field, members: engine.members, projects: engine.projects)
        Section {
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), alignment: .leading)], alignment: .leading) {
                    toggles(options)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("filter.values.\(index)")
                #else
                Menu(FilterOptions.summary(filter, options: options)) { toggles(options) }
                    .menuActionDismissBehavior(.disabled)
                    .accessibilityIdentifier("filter.values.button.\(index)")
                #endif
            }
            #if os(iOS)
            removeButton
            #endif
        } header: {
            #if os(macOS)
            HStack {
                Text(title)
                Spacer()
                removeButton
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .help("Remove Filter")
            }
            #else
            Text(title)
            #endif
        }
    }

    private var title: String { index == 0 ? "Where" : "And" }

    private var removeButton: some View {
        Button(role: .destructive) {
            engine.model.removeFilter(at: index)
        } label: {
            #if os(macOS)
            Label("Remove Filter", systemImage: "minus.circle")
            #else
            Text("Remove Filter")
            #endif
        }
        .accessibilityIdentifier("filter.remove.\(index)")
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
