public protocol ProjectScoped {
    var project: Project? { get }
}

extension TaskItem: ProjectScoped {}
extension Milestone: ProjectScoped {}
extension CalendarEvent: ProjectScoped {}

extension Sequence where Element: ProjectScoped {
    public func inLiveProjects() -> [Element] {
        filter { $0.project?.isArchived == false }
    }
}
