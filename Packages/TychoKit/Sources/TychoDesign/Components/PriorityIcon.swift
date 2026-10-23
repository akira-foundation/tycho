import SwiftUI

public struct PriorityIcon: View {
    private let weight: Int
    private let size: CGFloat

    public init(weight: Int, size: CGFloat = 14) {
        self.weight = weight
        self.size = size
    }

    public static func filledBars(for weight: Int) -> Int { min(max(weight, 0), 3) }

    public var body: some View {
        Group {
            switch weight {
            case 4...:
                Image(systemName: "exclamationmark.square.fill")
                    .font(.system(size: size))
                    .foregroundStyle(Token.red.color)
            case ...0:
                Image(systemName: "minus")
                    .font(.system(size: size * 0.8, weight: .semibold))
                    .foregroundStyle(Token.text4.color)
            default:
                HStack(alignment: .bottom, spacing: 1.5) {
                    ForEach(1...3, id: \.self) { bar in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(bar <= Self.filledBars(for: weight) ? Token.text2.color : Token.border.color)
                            .frame(width: 3, height: size * (0.35 + 0.2 * CGFloat(bar)))
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
