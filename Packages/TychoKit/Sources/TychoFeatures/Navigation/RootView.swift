import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct RootView: View {
    @Environment(Router.self) private var router
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    var body: some View {
        content
            .onChange(of: workspaces.first?.id) {
                router.isCreatingTask = false
                router.isCreatingProject = false
                router.closeInspector()
                router.open(.home)
            }
    }

    @ViewBuilder private var content: some View {
        @Bindable var router = router
        if workspaces.isEmpty {
            OnboardingView()
        } else {
            NavigationSplitView(columnVisibility: $router.columnVisibility) {
                SidebarView()
            } detail: {
                NavigationStack {
                    RouteDetail(route: router.route)
                }
            }
            .background(Token.bg.color)
            #if os(macOS)
            .onGeometryChange(for: CGFloat.self) {
                $0.size.width
            } action: {
                router.windowWidth = $0
            }
            #endif
            .toolbar {
                ToolbarItem {
                    Button("Inspector", systemImage: "sidebar.right") { router.closeInspector() }
                        .disabled(router.inspectedTaskID == nil)
                        .accessibilityIdentifier("toolbar.inspector")
                }
            }
            .inspector(
                isPresented: Binding(
                    get: { router.isInspectorColumnPresented },
                    set: { if !$0 && !router.inspectsInSheet { router.closeInspector() } }
                )
            ) {
                if let id = router.inspectedTaskID {
                    TaskInspectorView(taskID: id, presentedAsSheet: inspectorIsSheet)
                        .id(id)
                        .inspectorColumnWidth(
                            min: InspectorLayout.minimumColumnWidth,
                            ideal: InspectorLayout.idealColumnWidth,
                            max: InspectorLayout.maximumColumnWidth)
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { router.isInspectorSheetPresented },
                    set: { if !$0 && router.inspectsInSheet { router.closeInspector() } }
                )
            ) {
                if let id = router.inspectedTaskID {
                    TaskInspectorView(taskID: id, presentedAsSheet: true)
                        .id(id)
                        .frame(
                            minWidth: InspectorLayout.minimumColumnWidth, idealWidth: InspectorLayout.idealColumnWidth,
                            minHeight: 560)
                }
            }
            .sheet(isPresented: $router.isCreatingProject) { NewProjectSheet(project: nil) }
            .sheet(isPresented: $router.isCreatingTask) {
                NewTaskSheet(status: router.draftStatus, due: router.draftDue)
            }
            .sheet(isPresented: $router.isShowingSettings) {
                NavigationStack { SettingsView() }
            }
        }
    }

    private var inspectorIsSheet: Bool {
        #if os(iOS)
        sizeClass == .compact
        #else
        false
        #endif
    }
}
