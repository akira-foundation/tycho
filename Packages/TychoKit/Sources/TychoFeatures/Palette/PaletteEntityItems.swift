import TychoCore

enum PaletteEntityItems {
    static func task(_ task: TaskItem) -> PaletteItem {
        PaletteItem(
            id: "task-\(task.id)", title: task.title, subtitle: task.project?.name,
            trailing: task.key, visual: .status(task.status), kind: .task, action: .openTask(task.id))
    }

    static func project(_ project: Project) -> PaletteItem {
        PaletteItem(
            id: "project-\(project.id)", title: project.name, subtitle: project.status.title,
            visual: .project(symbol: project.symbol, color: project.color), kind: .project,
            action: .openProject(project.id))
    }

    static func file(_ file: FileRecord) -> PaletteItem {
        PaletteItem(
            id: "file-\(file.id)", title: file.name, subtitle: file.project?.name,
            trailing: ByteCountText.format(file.byteCount), visual: .file(file.kind),
            kind: .file, action: .openFile(file.id))
    }

    static func groups(scope: SearchScope, results: SearchResults) -> [PaletteSection] {
        let limit = scope == .all ? 4 : 12
        let showsTasks = scope == .all || scope == .tasks
        let showsProjects = scope == .all || scope == .projects
        let showsFiles = scope == .all || scope == .files
        let groups = [
            PaletteSection(
                id: "tasks", title: "Tasks",
                items: showsTasks ? results.tasks.prefix(limit).map(task) : []),
            PaletteSection(
                id: "projects", title: "Projects",
                items: showsProjects ? results.projects.prefix(limit).map(project) : []),
            PaletteSection(
                id: "files", title: "Files",
                items: showsFiles ? results.files.prefix(limit).map(file) : []),
        ]
        return groups.filter { !$0.items.isEmpty }
    }
}
