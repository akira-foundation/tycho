import Foundation
import SwiftData
import TychoCore

@MainActor
enum FileUpload {
    static func perform(_ urls: [URL], project: Project, task: TaskItem?, context: ModelContext, toast: ToastCenter) {
        var uploaded: [String] = []
        var firstFailure: String?
        for url in urls {
            do {
                let (name, data) = try FileImport.read(url)
                try FileActions(context: context).add(
                    name: name, data: data, to: project, task: task, by: project.workspace?.me)
                uploaded.append(name)
            } catch let error as ValidationError {
                firstFailure = firstFailure ?? error.userMessage
            } catch {
                firstFailure = firstFailure ?? "Couldn't save changes."
                toast.report(error)
            }
        }
        guard let message = summary(uploaded: uploaded, failure: firstFailure, total: urls.count) else { return }
        toast.show(message)
    }

    private static func summary(uploaded: [String], failure: String?, total: Int) -> String? {
        switch (failure, total) {
        case (nil, 0): nil
        case (nil, 1): "Uploaded \(uploaded[0])"
        case (nil, _): "Uploaded \(total) files"
        case (let failure?, 1): failure
        case (let failure?, _): "\(failure) (\(uploaded.count) of \(total) uploaded)"
        }
    }
}
