import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ToastCenterTests {
    private struct Failure: Error {}

    @Test func reportShowsTheGenericSaveMessage() {
        let toast = ToastCenter()

        toast.report(Failure())

        #expect(toast.message == "Couldn't save changes.")
    }

    @Test func performReportsUnexpectedErrors() {
        let toast = ToastCenter()

        toast.perform { throw Failure() }

        #expect(toast.message == "Couldn't save changes.")
    }

    @Test func dependencyErrorsExplainThemselves() {
        #expect(ValidationError.dependencyOnSelf.userMessage == "A task can't depend on itself.")
        #expect(ValidationError.dependencyAcrossProjects.userMessage == "Dependencies must be in the same project.")
        #expect(ValidationError.dependencyCycle.userMessage == "These tasks would block each other.")
    }

    @Test func largeFilesExplainTheLimit() {
        #expect(ValidationError.fileTooLarge.userMessage == "Files can be up to 250 MB each.")
    }
}
