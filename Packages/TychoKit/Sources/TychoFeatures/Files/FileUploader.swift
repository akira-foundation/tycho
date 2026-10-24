import SwiftData
import SwiftUI
import TychoCore
import UniformTypeIdentifiers

private struct FileUploaderModifier: ViewModifier {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Binding var isPresented: Bool
    let project: Project?
    let task: TaskItem?

    func body(content: Content) -> some View {
        content.fileImporter(
            isPresented: $isPresented, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: handle
        )
    }

    private func handle(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            FileUpload.perform(urls, project: project, task: task, context: context, toast: toast)
        case .failure(let error):
            toast.report(error)
        }
    }
}

extension View {
    func fileUploader(isPresented: Binding<Bool>, project: Project?, task: TaskItem? = nil) -> some View {
        modifier(FileUploaderModifier(isPresented: isPresented, project: project, task: task))
    }

    func filePreview(item: Binding<FileRecord?>) -> some View {
        sheet(item: item) { FilePreviewSheet(file: $0) }
    }
}
