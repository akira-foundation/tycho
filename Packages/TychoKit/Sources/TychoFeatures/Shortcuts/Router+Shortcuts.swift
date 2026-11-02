import SwiftUI

extension Router {
    public var hasModalPresentation: Bool {
        palette != nil || isCreatingTask || isCreatingProject || isShowingSettings || isShowingShortcuts
            || isInspectorSheetPresented || isShowingLocalSheet
    }

    public var blocksNavigationCommands: Bool {
        palette == nil && hasModalPresentation
    }

    func resetForNewWorkspace() {
        isCreatingTask = false
        isCreatingProject = false
        isShowingShortcuts = false
        isShowingSettings = false
        closePalette()
        closeInspector()
        open(.home)
    }

    public func toggleSidebar() {
        columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
    }

    public func showShortcuts() {
        isShowingShortcuts = true
    }

    public func perform(_ action: ShortcutAction) {
        switch action {
        case .palette: togglePalette()
        case .search: openPalette(mode: .search)
        case .newTask: newTask()
        case .newProject: newProject()
        case .shortcuts: showShortcuts()
        case .toggleSidebar: toggleSidebar()
        case .go(let route): open(route)
        case .settings: showSettings()
        }
    }
}
