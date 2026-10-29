import Foundation
import TychoCore

public enum PaletteSuggestions {
    static let websiteKey = "WEB"
    static let highPriorityViewName = "High priority"

    public static func items(projects: [Project], savedViews: [SavedView]) -> [PaletteItem] {
        var items = [
            PaletteItem(
                id: "suggest-overdue", title: "Overdue tasks", symbol: "clock.badge.exclamationmark",
                kind: .suggestion, action: .tasksPreset(.overdue)),
            PaletteItem(
                id: "suggest-mine", title: "Tasks assigned to me", symbol: "person",
                kind: .suggestion, action: .go(.myTasks)),
        ]
        guard let website = projects.first(where: { $0.key == websiteKey }) else { return items }
        if let view = savedViews.first(where: {
            $0.project?.id == website.id && $0.name == highPriorityViewName
        }) {
            items.append(
                PaletteItem(
                    id: "suggest-high", title: "High priority in Website Redesign",
                    symbol: "cellularbars", kind: .suggestion,
                    action: .go(.project(website.id, .savedView(view.id)))))
        }
        items.append(
            PaletteItem(
                id: "suggest-files", title: "Files in Website Redesign", symbol: "paperclip",
                kind: .suggestion, action: .go(.project(website.id, .files))))
        return items
    }
}
