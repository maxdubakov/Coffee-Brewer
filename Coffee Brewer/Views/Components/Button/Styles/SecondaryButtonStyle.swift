import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            .foregroundColor(BrewerColors.cream)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: maxWidth)
            .background(
                ZStack {
                    BrewerColors.surface
                    if configuration.isPressed {
                        BrewerColors.buttonHighlight
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [BrewerColors.cream.opacity(0.8), BrewerColors.cream.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
