import SwiftUI
import TychoCore

extension TaskTableView {
    @TableColumnBuilder<TaskItem, TaskComparator>
    var columns: some TableColumnContent<TaskItem, TaskComparator> {
        TableColumn("Task", sortUsing: TaskComparator(field: .title)) { TitleCell(task: $0) }
            .width(min: CGFloat(TableColumnID.minimumWidth), ideal: CGFloat(TableColumnID.title.defaultWidth))
            .customizationID(TableColumnID.title.rawValue)
            .disabledCustomizationBehavior([.visibility, .reorder])
        TableColumn("Status", sortUsing: TaskComparator(field: .status)) { StatusCell(task: $0) }
            .tychoColumn(.status)
        TableColumn("Priority", sortUsing: TaskComparator(field: .priority)) { PriorityCell(task: $0) }
            .tychoColumn(.priority)
        TableColumn("Assignee", sortUsing: TaskComparator(field: .assignee)) {
            AssigneeCell(task: $0, members: members)
        }
        .tychoColumn(.assignee)
        TableColumn("Created", sortUsing: TaskComparator(field: .created)) { CreatedCell(task: $0) }
            .tychoColumn(.created)
        TableColumn("Project", sortUsing: TaskComparator(field: .project)) { ProjectCell(task: $0) }
            .tychoColumn(.project)
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
