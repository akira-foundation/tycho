import SwiftUI
import TychoCore
import TychoDesign

struct ProjectCard: View {
    let project: Project
    @Environment(\.dateText) private var dateText

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 24)
                Text(project.name).font(.headline).lineLimit(1)
                Spacer()
                if project.isFavorite {
                    Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                }
            }
            Text(project.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
            StatusPill(status: project.status)
            ProgressView(value: Double(project.progress), total: 100).tint(project.color.tint)
            HStack {
                AvatarStack(people: (project.members ?? []).map { ($0.initials, $0.tint) })
                Spacer()
                if let due = project.due {
                    Text(dateText.short(due))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(project.progress)%").font(.caption).monospacedDigit().foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.fill.quinary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct StatusPill: View {
    let status: ProjectStatus

    var body: some View {
        Text(status.title)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .frame(height: 20)
            .foregroundStyle(status.tint)
            .background(status.tint.opacity(0.12), in: Capsule())
    }
}
