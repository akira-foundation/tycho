import Foundation
import Testing

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
}
