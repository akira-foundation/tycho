import SwiftUI
import TychoCore
import TychoDesign

struct FilterBuilder: View {
    let model: TaskViewModel
    let members: [Member]
    let projects: [Project]

    @State private var openIndex: Int?

    var body: some View {
        let filters = model.state.filters
        VStack(alignment: .leading, spacing: Spacing.s3) {
            header(hasFilters: !filters.isEmpty)
            if filters.isEmpty {
                Text(
                    "No filters applied. Combine filters to narrow the task list, e.g. Status is In Progress and Assignee is Sarah."
                )
                .tychoFont(.sm)
                .foregroundStyle(Token.text3.color)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                    FilterRow(
                        model: model, index: index, filter: filter, members: members, projects: projects,
                        openIndex: $openIndex)
                }
            }
            Divider()
            footer
        }
        .padding(Spacing.s4)
        .frame(minWidth: 440, idealWidth: 500, maxWidth: 560)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("filter.builder")
    }

    private func header(hasFilters: Bool) -> some View {
        HStack {
            Text("Filter by")
                .tychoFont(.xs, weight: .semibold)
                .foregroundStyle(Token.text3.color)
            Spacer()
            if hasFilters {
                Button("Clear all") { model.clearFilters() }
                    .buttonStyle(.plain)
                    .tychoFont(.xs)
                    .foregroundStyle(Token.text2.color)
                    .accessibilityIdentifier("filter.clear")
            }
        }
    }

    private var footer: some View {
        HStack(alignment: .top, spacing: Spacing.s2) {
            Text("Add filter:")
                .tychoFont(.xs)
                .foregroundStyle(Token.text3.color)
            FlowLayout(spacing: Spacing.s1) {
                ForEach(TaskFilterField.allCases, id: \.self) { field in
                    Button(field.title, systemImage: field.symbol) {
                        let index = model.addFilter(field)
                        Task { @MainActor in
                            await RunLoopTurn.next()
                            openIndex = index
                        }
                    }
                    .buttonStyle(.tycho(.secondary, size: .sm))
                    .accessibilityIdentifier("filter.add.\(field.rawValue)")
                }
            }
        }
    }
}
