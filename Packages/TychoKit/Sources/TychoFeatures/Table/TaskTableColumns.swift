import SwiftUI
import TychoCore

extension TaskTableView {
    func cell<Content: View>(_ content: Content) -> some View {
        content.environment(toast).environment(router)
    }

    @TableColumnBuilder<TaskItem, TaskComparator>
    var columns: some TableColumnContent<TaskItem, TaskComparator> {
        Group {
            TableColumn("Task", sortUsing: TaskComparator(field: .title)) { cell(TitleCell(task: $0)) }
                .width(min: CGFloat(TableColumnID.minimumWidth), ideal: CGFloat(TableColumnID.title.defaultWidth))
                .customizationID(TableColumnID.title.rawValue)
                .disabledCustomizationBehavior([.visibility, .reorder])
            TableColumn("Status", sortUsing: TaskComparator(field: .status)) { cell(StatusCell(task: $0)) }
                .tychoColumn(.status)
            TableColumn("Priority", sortUsing: TaskComparator(field: .priority)) { cell(PriorityCell(task: $0)) }
                .tychoColumn(.priority)
            TableColumn("Assignee", sortUsing: TaskComparator(field: .assignee)) {
                cell(AssigneeCell(task: $0, members: members))
            }
            .tychoColumn(.assignee)
            TableColumn("Due date", sortUsing: TaskComparator(field: .due)) {
                cell(DateCell(task: $0, keyPath: \.due, highlightsOverdue: true))
            }
            .tychoColumn(.due)
            TableColumn("Start date", sortUsing: TaskComparator(field: .start)) {
                cell(DateCell(task: $0, keyPath: \.start, highlightsOverdue: false))
            }
            .tychoColumn(.start)
        }
        Group {
            TableColumn("Labels", sortUsing: TaskComparator(field: .manual)) { cell(LabelsCell(task: $0)) }
                .tychoColumn(.labels)
            TableColumn("Dependencies", sortUsing: TaskComparator(field: .manual)) {
                cell(DependencyPicker(task: $0, showsTitles: false, emptyText: "—"))
            }
            .tychoColumn(.deps)
            TableColumn("Estimate", sortUsing: TaskComparator(field: .estimate)) { cell(EstimateCell(task: $0)) }
                .tychoColumn(.estimate)
            TableColumn("Created", sortUsing: TaskComparator(field: .created)) { cell(CreatedCell(task: $0)) }
                .tychoColumn(.created)
            TableColumn("Project", sortUsing: TaskComparator(field: .project)) { cell(ProjectCell(task: $0)) }
                .tychoColumn(.project)
        }
    }
}

@MainActor
extension TableColumn where RowValue == TaskItem {
    func tychoColumn(_ id: TableColumnID) -> some TableColumnContent<TaskItem, Sort> {
        width(min: CGFloat(TableColumnID.minimumWidth), ideal: CGFloat(id.defaultWidth))
            .customizationID(id.rawValue)
            .disabledCustomizationBehavior(.reorder)
    }
}
