import Foundation
import TychoCore

enum FileSort: String, CaseIterable, Identifiable {
    case newest
    case name
    case type

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newest: "Sort: Newest"
        case .name: "Sort: Name"
        case .type: "Sort: Type"
        }
    }
}

enum FileLayout: String {
    case grid
    case list
}

enum FileQuery {
    static let filterKinds = FileKind.allCases.filter { $0 != .other }

    static func isFiltering(search: String, kind: FileKind?) -> Bool {
        !search.isEmpty || kind != nil
    }

    static func apply(_ files: [FileRecord], search: String, kind: FileKind?, sort: FileSort) -> [FileRecord] {
        let needle = search.lowercased()
        let matching = files.filter { file in
            (needle.isEmpty || file.name.lowercased().contains(needle)) && (kind == nil || file.kind == kind)
        }
        switch sort {
        case .newest: return matching.sorted { $0.uploadedAt > $1.uploadedAt }
        case .name: return matching.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .type: return matching.sorted { ($0.typeRaw, $1.uploadedAt) < ($1.typeRaw, $0.uploadedAt) }
        }
    }
}
