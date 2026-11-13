import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.self) private var environment
    @Environment(\.displayScale) private var displayScale
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]
    @Query(sort: \Member.name) private var members: [Member]
    private let project: Project?
    @State private var draft: ProjectDraft
    @State private var keyEdited: Bool
    @State private var hasStart: Bool
    @State private var hasDue: Bool
    @State private var error: ValidationError?
    @State private var didSave = false
    @FocusState private var isNameFocused: Bool

    init(project: Project?) {
        self.project = project
        _draft = State(initialValue: project.map(ProjectDraft.init(project:)) ?? ProjectDraft(name: "", key: ""))
        _keyEdited = State(initialValue: project != nil)
        _hasStart = State(initialValue: project?.start != nil)
        _hasDue = State(initialValue: project?.due != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name, prompt: Text("Name"))
                        .labelsHidden()
                        .marksTextEditing(isFocused: isNameFocused)
                        .focused($isNameFocused)
                        .onSubmit(save)
                        .accessibilityIdentifier("project.name")
                        .onChange(of: draft.name) { _, name in
                            error = nil
                            if !keyEdited { draft.key = ProjectSymbols.suggestedKey(for: name) }
                        }
                    TextField("Description", text: $draft.summary, prompt: Text("Description"), axis: .vertical)
                        .labelsHidden()
                        .lineLimit(3...6)
                        .marksTextEditing()
                        .accessibilityIdentifier("project.summary")
                } footer: {
                    if let error {
                        Text(error.userMessage).foregroundStyle(.red).accessibilityIdentifier("project.error")
                    }
                }
                Section {
                    TextField(
                        "Key",
                        text: Binding(
                            get: { draft.key },
                            set: {
                                draft.key = $0; keyEdited = true
                            })
                    )
                    .marksTextEditing()
                    .onSubmit(save)
                    .accessibilityIdentifier("project.key")
                    Picker("Status", selection: $draft.status) {
                        ForEach(ProjectStatus.allCases) { status in
                            Label {
                                Text(status.title)
                            } icon: {
                                swatch(status.tint)
                            }.tag(status)
                        }
                    }
                    Picker("Lead", selection: $draft.lead) {
                        Text("No lead").tag(Member?.none)
                        ForEach(members) { Text($0.name).tag(Member?.some($0)) }
                    }
                    Picker("Color", selection: $draft.color) {
                        ForEach(ProjectColor.allCases) { color in
                            Label {
                                Text(color.rawValue.capitalized)
                            } icon: {
                                swatch(color.tint)
                            }.tag(color)
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 8) {
                        ForEach(ProjectSymbols.all, id: \.self) { symbol in
                            Button {
                                draft.symbol = symbol
                            } label: {
                                ProjectGlyph(
                                    symbol: symbol,
                                    color: draft.symbol == symbol ? draft.color.tint : Color.secondary, size: 32)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(symbol)
                        }
                    }
                }
                Section {
                    Toggle("Start date", isOn: $hasStart)
                        .toggleStyle(TychoToggleStyle())
                        .accessibilityIdentifier("project.hasStart")
                    if hasStart {
                        LabeledContent("Start") {
                            CalendarField(
                                title: "Start",
                                selection: Binding(get: { draft.start ?? .now }, set: { draft.start = $0 }))
                        }
                        .accessibilityIdentifier("project.start")
                    }
                    Toggle("Due date", isOn: $hasDue)
                        .toggleStyle(TychoToggleStyle())
                    if hasDue {
                        LabeledContent("Due") {
                            CalendarField(
                                title: "Due", selection: Binding(get: { draft.due ?? .now }, set: { draft.due = $0 }))
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(project == nil ? "New project" : "Edit project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(project == nil ? "Create" : "Save", role: .confirm, action: save)
                        .keyboardShortcut(.defaultAction)
                        .disabled(project == nil && workspaces.isEmpty)
                        .accessibilityIdentifier("project.save")
                }
            }
        }
        .frame(minWidth: 420, minHeight: 600)
        .onAppear { isNameFocused = true }
    }

    private func swatch(_ color: Color) -> Image {
        MenuSwatch.image(color.resolve(in: environment), scale: displayScale)
    }

    private func save() {
        guard !didSave else { return }
        var final = draft
        if !hasStart { final.start = nil }
        if !hasDue { final.due = nil }
        do {
            let actions = ProjectActions(context: context)
            switch (project, workspaces.first) {
            case (let project?, _):
                try actions.update(project, with: final)
            case (nil, let workspace?):
                let created = try actions.create(final, in: workspace)
                router.openProject(created.id, tab: .board)
            case (nil, nil):
                break
            }
            didSave = true
            dismiss()
        } catch let validation as ValidationError {
            error = validation
        } catch {
            toast.report(error)
        }
    }
}
