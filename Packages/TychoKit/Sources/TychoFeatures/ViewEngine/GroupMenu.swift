import SwiftUI
import TychoCore
import TychoDesign

struct GroupMenu: View {
    let model: TaskViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            Text("Group by")
                .tychoFont(.xs, weight: .semibold)
                .foregroundStyle(Token.text3.color)
            ForEach(TaskViewGrouping.allCases, id: \.self) { grouping in
                Button {
                    model.setGrouping(grouping)
                } label: {
                    HStack {
                        Text(grouping.title)
                        Spacer()
                        if model.state.grouping == grouping {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("view.group.\(grouping.rawValue)")
            }
        }
        .padding(Spacing.s3)
        .frame(width: 200)
    }
}
