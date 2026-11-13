import SwiftUI
import TychoCore

struct ProjectSummaryTile: View {
    let project: Project
    @Environment(\.dateText) private var dateText

    private var members: [Member] { project.members ?? [] }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                header
                Text(project.summary)
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(project.progress)%")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .monospacedDigit()
                    Text(ProjectGroup.detailLine(for: project))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                ProgressView(value: Double(project.progress), total: 100)
                    .tint(project.color.tint)
                footer
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(6)
        }
        .contentShape(Rectangle())
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Label(project.name, systemImage: project.symbol)
                .font(.headline)
                .foregroundStyle(project.color.tint)
                .lineLimit(1)
            if project.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .imageScale(.small)
                    .accessibilityLabel("Favorite")
            }
            Spacer(minLength: 8)
            Label(project.status.title, systemImage: project.status.symbol)
                .font(.callout)
                .foregroundStyle(project.status.tint)
                .lineLimit(1)
        }
    }

    private var footer: some View {
        HStack {
            if let due = project.due {
                Label(dateText.short(due), systemImage: "calendar")
            }
            Spacer(minLength: 8)
            Text(
                "^[\(members.count) member](inflect: true) · Updated \(project.updatedAt, format: .relative(presentation: .named))"
            )
            .lineLimit(1)
            .help(members.map(\.name).sorted().joined(separator: ", "))
        }
    }
}
