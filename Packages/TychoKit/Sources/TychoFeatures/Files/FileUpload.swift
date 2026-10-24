import Foundation
import SwiftData
import TychoCore

@MainActor
enum FileUpload {
    static func perform(_ urls: [URL], project: Project, task: TaskItem?, context: ModelContext, toast: ToastCenter) {
        for url in urls {
            do {
                let (name, data) = try FileImport.read(url)
                try FileActions(context: context).add(
                    name: name, data: data, to: project, task: task, by: project.workspace?.me)
                toast.show("Uploaded \(name)")
            } catch let error as ValidationError {
                toast.show(error.userMessage)
            } catch {
                toast.report(error)
            }
        }
    }
}
