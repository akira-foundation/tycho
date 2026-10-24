public enum ValidationError: Error, Equatable, Sendable {
    case emptyTitle
    case emptyName
    case invalidProjectKey
    case duplicateProjectKey
    case dependencyOnSelf
    case dependencyAcrossProjects
    case dependencyCycle
    case fileTooLarge
}
