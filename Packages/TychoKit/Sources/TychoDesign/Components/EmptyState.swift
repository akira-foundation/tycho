import SwiftUI

public struct EmptyState: View {
    private let title: String
    private let symbol: String
    private let message: String

    public init(title: String, symbol: String, message: String) {
        self.title = title
        self.symbol = symbol
        self.message = message
    }

    public var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
            .foregroundStyle(Token.text3.color)
    }
}
