import SwiftUI

struct RecipeContinueButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            StandardButton(
                title: title,
                iconName: "arrow.right.circle.fill",
                action: action,
                style: .primary
            )
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .padding(.bottom, 40)
    }
}