import SwiftUI

public struct TychoSegmented<Value: Hashable>: View {
    @Binding private var selection: Value
    private let options: [Value]
    private let title: (Value) -> String

    public init(selection: Binding<Value>, options: [Value], title: @escaping (Value) -> String) {
        _selection = selection
        self.options = options
        self.title = title
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                Segment(title: title(option), isSelected: option == selection) { selection = option }
            }
        }
        .padding(2)
        .background(Token.surface3.color, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        .fixedSize()
        .accessibilityElement(children: .contain)
    }

    private struct Segment: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        @State private var hovering = false

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)
            Button(action: action) {
                Text(title)
                    .tychoFont(.xs, weight: .medium)
                    .foregroundStyle(isSelected || hovering ? Token.text.color : Token.text2.color)
                    .padding(.horizontal, 9)
                    .frame(height: ButtonSize.sm.height - 2)
                    .background { if isSelected { selectedBackground(shape) } }
                    .contentShape(shape)
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }

        private func selectedBackground(_ shape: RoundedRectangle) -> some View {
            shape.fill(Token.surface.color)
                .overlay(shape.strokeBorder(Token.border.color, lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
        }
    }
}
