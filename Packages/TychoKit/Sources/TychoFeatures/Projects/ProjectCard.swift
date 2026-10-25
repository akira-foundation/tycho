import SwiftUI
import TychoCore
import TychoDesign

struct ProjectCard: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            HStack(spacing: Spacing.s2) {
                ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 24)
                Text(project.name).tychoFont(.md, weight: .semibold).lineLimit(1)
                Spacer()
                if project.isFavorite {
                    Image(systemName: "star.fill").foregroundStyle(Token.amber.color).font(.caption)
                }
            }
            Text(project.summary)
                .tychoFont(.sm)
                .foregroundStyle(Token.text3.color)
                .lineLimit(2, reservesSpace: true)
            StatusPill(status: project.status)
            ProgressView(value: Double(project.progress), total: 100).tint(project.color.tint)
            HStack {
                AvatarStack(people: (project.members ?? []).map { ($0.initials, $0.tint) })
                Spacer()
                if let due = project.due {
                    Text(due, format: .dateTime.month(.abbreviated).day())
                        .tychoFont(.xs)
                        .foregroundStyle(Token.text3.color)
                }
                Text("\(project.progress)%").tychoFont(.xs).monospacedDigit().foregroundStyle(Token.text3.color)
            }
        }
        .padding(Spacing.s4)
        .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .shadowCard(radius: Radius.lg)
    }
}

struct StatusPill: View {
    let status: ProjectStatus

    var body: some View {
        Text(status.title)
            .tychoFont(.xxs, weight: .medium)
            .padding(.horizontal, Spacing.s2)
            .frame(height: 20)
            .foregroundStyle(status.tint)
            .background(status.tint.opacity(0.12), in: Capsule())
    }
}
