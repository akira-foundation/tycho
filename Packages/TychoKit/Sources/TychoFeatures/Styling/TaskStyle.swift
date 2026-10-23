import SwiftUI
import TychoCore
import TychoDesign

extension TaskStatus {
    public var glyph: StatusGlyph {
        switch self {
        case .backlog: .dashed
        case .todo: .partial(0)
        case .progress: .partial(0.5)
        case .review: .partial(0.75)
        case .done: .done
        }
    }

    public var token: Token {
        switch self {
        case .backlog: .stBacklog
        case .todo: .stTodo
        case .progress: .stProgress
        case .review: .stReview
        case .done: .stDone
        }
    }

    public var tint: Color { token.color }
}

extension TaskLabel {
    public var token: Token {
        switch self {
        case .design: .violet
        case .frontend: .blue
        case .backend: .teal
        case .research: .amber
        case .content: .rose
        case .bug: .red
        case .qa: .green
        case .growth: .orange
        }
    }

    public var tint: Color { token.color }
}
