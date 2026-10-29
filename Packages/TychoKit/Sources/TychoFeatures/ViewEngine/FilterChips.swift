import SwiftUI
import TychoCore
import TychoDesign

struct FilterChips: View {
    let model: TaskViewModel
    let members: [Member]
    let projects: [Project]

    @State private var openIndex: Int?

    var body: some View {
        let filters = model.state.filters
        if !filters.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s2) {
                    ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                        if index > 0 {
                            Text("and")
                                .tychoFont(.xs)
                                .foregroundStyle(Token.text3.color)
                        }
                        chip(index: index, filter: filter)
                    }
                    Button("Add", systemImage: "plus") { openIndex = model.addFilter(.status) }
                        .buttonStyle(.tycho(.secondary, size: .sm))
                        .accessibilityIdentifier("filter.chips.add")
                    Button("Clear all") { model.clearFilters() }
                        .buttonStyle(.plain)
                        .tychoFont(.xs)
                        .foregroundStyle(Token.text2.color)
                        .accessibilityIdentifier("filter.chips.clear")
                }
                .padding(.horizontal, Spacing.s4)
                .padding(.vertical, Spacing.s1)
            }
        }
    }

    private func chip(index: Int, filter: TaskFilter) -> some View {
        let options = FilterOptions.options(for: filter.field, members: members, projects: projects)
        return HStack(spacing: Spacing.s1) {
            Button {
                openIndex = index
            } label: {
                HStack(spacing: Spacing.s1) {
                    Image(systemName: filter.field.symbol)
                    Text("\(filter.field.title) \(filter.op.title) \(FilterOptions.summary(filter, options: options))")
                        .lineLimit(1)
                }
                .tychoFont(.xs)
                .foregroundStyle(Token.text.color)
            }
            .buttonStyle(.plain)
            .popover(
                isPresented: Binding(
                    get: { openIndex == index },
                    set: { if !$0, openIndex == index { openIndex = nil } }
                )
            ) {
                FilterValueList(model: model, index: index, options: options)
            }
            .accessibilityIdentifier("filter.chip.\(index)")
            Button("Remove filter", systemImage: "xmark") { model.removeFilter(at: index) }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .tychoFont(.xxs)
                .foregroundStyle(Token.text3.color)
                .accessibilityIdentifier("filter.chip.remove.\(index)")
        }
        .padding(.horizontal, Spacing.s2)
        .padding(.vertical, Spacing.s1)
        .background(Token.surface2.color, in: Capsule())
        .overlay(Capsule().stroke(Token.border.color))
    }
}
