import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(BrewerColors.espresso)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: maxWidth)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [BrewerColors.caramel, BrewerColors.cream]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
            .buttonPressAnimation(isPressed: configuration.isPressed)
    }
}
