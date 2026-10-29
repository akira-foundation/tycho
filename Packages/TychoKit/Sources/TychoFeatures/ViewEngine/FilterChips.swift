import SwiftUI
import TychoCore
import TychoDesign

struct FilterChips: View {
    let model: TaskViewModel
    let members: [Member]
    let projects: [Project]

    private static let chipHeight: CGFloat = 24

    @State private var openIndex: Int?
    @State private var showingBuilder = false

    var body: some View {
        let filters = model.state.filters
        if !filters.isEmpty {
            HStack(alignment: .top, spacing: Spacing.s2) {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(Token.text3.color)
                    .frame(height: Self.chipHeight)
                FlowLayout(spacing: Spacing.s2) {
                    ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                        if index > 0 {
                            Text("and")
                                .tychoFont(.xs)
                                .foregroundStyle(Token.text3.color)
                                .frame(height: Self.chipHeight)
                        }
                        chip(index: index, filter: filter)
                    }
                    addButton
                }
                Spacer(minLength: Spacing.s2)
                Button("Clear all") {
                    openIndex = nil
                    model.clearFilters()
                }
                .buttonStyle(.plain)
                .tychoFont(.xs)
                .foregroundStyle(Token.text2.color)
                .frame(height: Self.chipHeight)
                .accessibilityIdentifier("filter.chips.clear")
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.vertical, Spacing.s1)
        }
    }

    private var addButton: some View {
        Button("Add", systemImage: "plus") { showingBuilder = true }
            .buttonStyle(.tycho(.secondary, size: .sm))
            .popover(isPresented: $showingBuilder) {
                FilterBuilder(model: model, members: members, projects: projects)
            }
            .accessibilityIdentifier("filter.chips.add")
    }

    private func chip(index: Int, filter: TaskFilter) -> some View {
        let options = FilterOptions.options(for: filter.field, members: members, projects: projects)
        return HStack(spacing: Spacing.s1) {
            Button {
                openIndex = index
            } label: {
                HStack(spacing: Spacing.s1) {
                    Image(systemName: filter.field.symbol)
                    Text(filter.field.title).fontWeight(.semibold)
                    Text("\(filter.op.title) \(FilterOptions.summary(filter, options: options))")
                        .lineLimit(1)
                }
                .tychoFont(.xs)
                .foregroundStyle(Token.text.color)
            }
            .buttonStyle(.plain)
            .popover(isPresented: .open($openIndex, at: index)) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(filter.field.title) \(filter.op.title)")
                        .tychoFont(.xs, weight: .semibold)
                        .foregroundStyle(Token.text3.color)
                        .padding(.horizontal, Spacing.s3)
                        .padding(.top, Spacing.s3)
                    FilterValueList(model: model, index: index, options: options)
                }
            }
            .accessibilityIdentifier("filter.chip.\(index)")
            Button("Remove filter", systemImage: "xmark") {
                openIndex = nil
                model.removeFilter(at: index)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .tychoFont(.xxs)
            .foregroundStyle(Token.text3.color)
            .accessibilityIdentifier("filter.chip.remove.\(index)")
        }
        .padding(.horizontal, Spacing.s2)
        .frame(height: Self.chipHeight)
        .background(Token.surface2.color, in: Capsule())
        .overlay(Capsule().stroke(Token.border.color))
    }
}
