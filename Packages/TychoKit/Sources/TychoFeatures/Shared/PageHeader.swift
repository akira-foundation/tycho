import SwiftUI
import TychoDesign

struct PageHeader<Actions: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let actions: Actions

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.s3) {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(title).tychoFont(.xxl, weight: .semibold)
                Text(subtitle).tychoFont(.base).foregroundStyle(Token.text3.color)
            }
            Spacer()
            actions
        }
        .padding(.horizontal, Spacing.s6)
        .padding(.vertical, Spacing.s4)
    }
}
