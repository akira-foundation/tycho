import SwiftData
import SwiftUI
import TychoCore
import UniformTypeIdentifiers

private struct FilePickerModifier: ViewModifier {
    @Environment(ToastCenter.self) private var toast
    @Binding var isPresented: Bool
    let onPick: ([URL]) -> Void

    func body(content: Content) -> some View {
        content.fileImporter(
            isPresented: $isPresented, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: handle
        )
    }

    private func handle(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            onPick(urls)
        case .failure(let error):
            toast.report(error)
        }
    }
}

private struct FileUploaderModifier: ViewModifier {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Binding var isPresented: Bool
    let task: TaskItem

    func body(content: Content) -> some View {
        content.pickFiles(isPresented: $isPresented) { urls in
            FileUpload.perform(urls, project: task.project, task: task, context: context, toast: toast)
        }
    }
}

extension View {
    func pickFiles(isPresented: Binding<Bool>, onPick: @escaping ([URL]) -> Void) -> some View {
        modifier(FilePickerModifier(isPresented: isPresented, onPick: onPick))
    }

    func fileUploader(isPresented: Binding<Bool>, task: TaskItem) -> some View {
        modifier(FileUploaderModifier(isPresented: isPresented, task: task))
    }

    func filePreview(item: Binding<FileRecord?>) -> some View {
        sheet(item: item) { FilePreviewSheet(file: $0) }
    }
}
