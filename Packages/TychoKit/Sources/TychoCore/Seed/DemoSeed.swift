import Foundation
import SwiftData

@MainActor
public enum DemoSeed {
    @discardableResult
    public static func load(into context: ModelContext, now: Date, calendar: Calendar) throws -> Workspace {
        let today = calendar.startOfDay(for: now)
        let date: (Int) -> Date = { offset in
            let shifted = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            return calendar.date(byAdding: .hour, value: 12, to: shifted) ?? shifted
        }

        let workspace = Workspace(name: "Gr8r Studio")
        context.insert(workspace)

        var teams: [String: Team] = [:]
        for seed in DemoSeedData.teams {
            let team = Team(
                slug: seed.slug, name: seed.name, symbol: seed.symbol, colorHex: seed.color, summary: seed.summary)
            context.insert(team)
            team.workspace = workspace
            teams[seed.slug] = team
        }

        var members: [String: Member] = [:]
        for seed in DemoSeedData.members {
            let member = Member(
                name: seed.name, email: seed.email, title: seed.title, colorHex: seed.color, role: seed.role,
                isMe: seed.ref == "m1")
            context.insert(member)
            member.workspace = workspace
            member.team = teams[seed.team]
            members[seed.ref] = member
        }

        var projects: [String: Project] = [:]
        for (index, seed) in DemoSeedData.projects.enumerated() {
            let project = Project(key: seed.key, name: seed.name)
            project.symbol = seed.symbol
            project.color = seed.color
            project.status = seed.status
            project.start = date(seed.start)
            project.due = date(seed.due)
            project.summary = seed.summary
            project.isFavorite = seed.favorite
            project.sortOrder = Double(index + 1) * Rank.step
            project.createdAt = date(seed.start)
            project.updatedAt = now.addingTimeInterval(-Double(seed.lastMinutes) * 60)
            context.insert(project)
            project.workspace = workspace
            project.team = teams[seed.team]
            project.lead = members[seed.lead]
            project.members = seed.members.compactMap { members[$0] }
            projects[seed.ref] = project
        }

        var countByProject: [String: Int] = [:]
        var doneIndex = 0
        var seededTasks: [TaskItem] = []
        for (index, seed) in DemoSeedData.tasks.enumerated() {
            let count = (countByProject[seed.project] ?? 0) + 1
            countByProject[seed.project] = count
            let task = TaskItem(number: 100 + count * 3, title: seed.title)
            task.status = seed.status
            task.priority = seed.priority
            task.labels = Set(seed.labels)
            task.due = seed.due.map(date)
            task.start = seed.due.map { date($0 - seed.length) }
            task.estimate = seed.estimate
            task.notes = seed.notes
            task.isFavorite = seed.favorite
            task.sortOrder = Double(index + 1) * Rank.step
            task.createdAt = now.addingTimeInterval(-Double(seed.ageDays) * 86_400)
            task.updatedAt = now.addingTimeInterval(-30 * 3600)
            if seed.status == .done {
                task.completedAt = now.addingTimeInterval(-Double(6 + doneIndex * 17) * 3600)
                doneIndex += 1
            }
            context.insert(task)
            seededTasks.append(task)
            task.project = projects[seed.project]
            task.assignee = members[seed.assignee]
            for (offset, subtaskSeed) in seed.subtasks.enumerated() {
                let subtask = Subtask(
                    title: subtaskSeed.0, isDone: subtaskSeed.1, sortOrder: Double(offset + 1) * Rank.step)
                context.insert(subtask)
                subtask.task = task
            }
        }

        for (ref, project) in projects {
            project.nextTaskNumber = 100 + (countByProject[ref] ?? 0) * 3 + 1
        }

        loadSchedule(into: context, projects: projects, members: members, tasks: seededTasks, now: now, date: date)

        try context.saveOrRollback()
        return workspace
    }
}
