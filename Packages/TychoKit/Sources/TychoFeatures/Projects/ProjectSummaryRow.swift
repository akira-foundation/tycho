import SwiftUI
import TychoCore

struct ProjectSummaryRow: View {
    let project: Project
    @Environment(\.dateText) private var dateText

    private var memberNames: String {
        (project.members ?? []).map(\.name).sorted().joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text(project.name)
                } icon: {
                    Image(systemName: project.symbol).frame(width: 20)
                }
                .font(.headline)
                .foregroundStyle(project.color.tint)
                if project.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)
                        .accessibilityLabel("Favorite")
                }
                Spacer()
                if let due = project.due {
                    Text(dateText.short(due)).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(project.progress, format: .number)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                Text("%").font(.headline).foregroundStyle(.secondary)
                Text(ProjectGroup.detailLine(for: project))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                Spacer()
                Label(project.status.title, systemImage: project.status.symbol)
                    .foregroundStyle(project.status.tint)
            }
            ProgressView(value: Double(project.progress), total: 100)
                .tint(project.color.tint)
            if !project.summary.isEmpty {
                Text(project.summary).foregroundStyle(.secondary).lineLimit(2)
            }
            footer.font(.footnote).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    @ViewBuilder private var footer: some View {
        let count = (project.members ?? []).count
        let updated = Text("Updated \(project.updatedAt, format: .relative(presentation: .named))")
        if count == 0 {
            updated
        } else {
            Text("^[\(count) member](inflect: true) · \(updated)")
                .help(memberNames)
        }
    }
}
