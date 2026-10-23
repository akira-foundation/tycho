public protocol Rankable: AnyObject {
    var sortOrder: Double { get set }
}

extension TaskItem: Rankable {}
extension Project: Rankable {}
extension Subtask: Rankable {}

public enum Rank {
    public static let step: Double = 1024
    public static let epsilon: Double = 1e-6

    public static func between(_ before: Double?, _ after: Double?) -> Double? {
        switch (before, after) {
        case (nil, nil):
            return step
        case (let before?, nil):
            return before + step
        case (nil, let after?):
            return after - step
        case (let before?, let after?):
            guard after - before > epsilon else { return nil }
            return (before + after) / 2
        }
    }

    public static func insert<T: Rankable>(_ item: T, into siblings: [T], at index: Int) {
        let others = siblings.filter { $0 !== item }
        let position = min(max(index, 0), others.count)
        let before = position > 0 ? others[position - 1].sortOrder : nil
        let after = position < others.count ? others[position].sortOrder : nil
        if let order = between(before, after) {
            item.sortOrder = order
            return
        }
        var ordered = others
        ordered.insert(item, at: position)
        for (offset, element) in ordered.enumerated() {
            element.sortOrder = Double(offset + 1) * step
        }
    }

    public static func appendOrder<T: Rankable>(after siblings: [T]) -> Double {
        (siblings.map(\.sortOrder).max() ?? 0) + step
    }
}
