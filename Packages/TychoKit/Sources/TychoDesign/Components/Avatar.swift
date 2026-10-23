import SwiftUI

public struct Avatar: View {
    private let initials: String
    private let color: Color
    private let size: CGFloat

    public init(initials: String, color: Color, size: CGFloat = 22) {
        self.initials = initials
        self.color = color
        self.size = size
    }

    public var body: some View {
        Text(initials)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color, in: Circle())
            .accessibilityLabel(initials)
    }
}

public struct AvatarStack: View {
    private let people: [(String, Color)]
    private let limit: Int

    public init(people: [(String, Color)], limit: Int = 3) {
        self.people = people
        self.limit = limit
    }

    public var body: some View {
        HStack(spacing: -6) {
            ForEach(Array(people.prefix(limit).enumerated()), id: \.offset) { _, person in
                Avatar(initials: person.0, color: person.1)
                    .overlay(Circle().strokeBorder(Token.surface.color, lineWidth: 1.5))
            }
            if people.count > limit {
                Text("+\(people.count - limit)")
                    .tychoFont(.xxs, weight: .medium)
                    .foregroundStyle(Token.text3.color)
                    .padding(.leading, Spacing.s2)
            }
        }
    }
}
