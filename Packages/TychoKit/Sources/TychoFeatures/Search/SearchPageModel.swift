import TychoCore

struct SearchPageModel {
    static func counts(_ results: SearchResults) -> [SearchScope: Int] {
        [
            .all: results.tasks.count + results.projects.count + results.files.count,
            .tasks: results.tasks.count,
            .projects: results.projects.count,
            .files: results.files.count,
        ]
    }

    static func sections(_ results: SearchResults, scope: SearchScope) -> [(title: String, count: Int)] {
        let candidates: [(scope: SearchScope, title: String, count: Int)] = [
            (.tasks, "Tasks", results.tasks.count),
            (.projects, "Projects", results.projects.count),
            (.files, "Files", results.files.count),
        ]
        return
            candidates
            .filter { ($0.scope == scope || scope == .all) && $0.count > 0 }
            .map { (title: "\($0.title) · \($0.count)", count: $0.count) }
    }
}
