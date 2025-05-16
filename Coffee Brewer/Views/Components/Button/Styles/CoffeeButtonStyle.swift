import SwiftUI

struct CoffeeButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(BrewerColors.textPrimary)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: maxWidth)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [BrewerColors.mocha, BrewerColors.espresso]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [BrewerColors.caramel.opacity(0.7), BrewerColors.caramel.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(12)
            .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
