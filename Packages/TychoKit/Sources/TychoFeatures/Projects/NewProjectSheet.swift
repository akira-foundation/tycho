import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]
    @Query(sort: \Member.name) private var members: [Member]
    private let project: Project?
    @State private var draft: ProjectDraft
    @State private var keyEdited: Bool
    @State private var hasStart: Bool
    @State private var hasDue: Bool
    @State private var error: ValidationError?

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
                    TextField("Name", text: $draft.name)
                        .accessibilityIdentifier("project.name")
                        .onChange(of: draft.name) { _, name in
                            error = nil
                            if !keyEdited { draft.key = ProjectSymbols.suggestedKey(for: name) }
                        }
                    TextField(
                        "Key",
                        text: Binding(
                            get: { draft.key },
                            set: {
                                draft.key = $0; keyEdited = true
                            })
                    )
                    .accessibilityIdentifier("project.key")
                    TextField("Description", text: $draft.summary, axis: .vertical).lineLimit(2...4)
                }
                Section("Appearance") {
                    Picker("Color", selection: $draft.color) {
                        ForEach(ProjectColor.allCases) { color in
                            Label(color.rawValue.capitalized, systemImage: "circle.fill").foregroundStyle(color.tint)
                                .tag(color)
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: Spacing.s2) {
                        ForEach(ProjectSymbols.all, id: \.self) { symbol in
                            Button {
                                draft.symbol = symbol
                            } label: {
                                ProjectGlyph(
                                    symbol: symbol,
                                    color: draft.symbol == symbol ? draft.color.tint : Token.text3.color, size: 32)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(symbol)
                        }
                    }
                }
                Section("Details") {
                    Picker("Status", selection: $draft.status) {
                        ForEach(ProjectStatus.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Lead", selection: $draft.lead) {
                        Text("No lead").tag(Member?.none)
                        ForEach(members) { Text($0.name).tag(Member?.some($0)) }
                    }
                    Toggle("Start date", isOn: $hasStart)
                        .toggleStyle(TychoToggleStyle())
                    if hasStart {
                        DatePicker(
                            "Start",
                            selection: Binding(
                                get: { draft.start ?? .now }, set: { draft.start = DatePill.normalized($0) }),
                            displayedComponents: .date)
                    }
                    Toggle("Due date", isOn: $hasDue)
                        .toggleStyle(TychoToggleStyle())
                    if hasDue {
                        DatePicker(
                            "Due",
                            selection: Binding(
                                get: { draft.due ?? .now }, set: { draft.due = DatePill.normalized($0) }),
                            displayedComponents: .date)
                    }
                }
                if let error {
                    Text(error.userMessage).foregroundStyle(Token.red.color).accessibilityIdentifier("project.error")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(project == nil ? "New project" : "Edit project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.buttonStyle(.tycho(.secondary))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(project == nil ? "Create" : "Save", action: save)
                        .buttonStyle(.tycho(.primary))
                        .keyboardShortcut(.return, modifiers: .command)
                        .disabled(project == nil && workspaces.isEmpty)
                        .accessibilityIdentifier("project.save")
                }
            }
        }
        .frame(minWidth: 420, minHeight: 520)
    }

    private func save() {
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
            dismiss()
        } catch let validation as ValidationError {
            error = validation
        } catch {
            toast.report(error)
        }
    }
}
