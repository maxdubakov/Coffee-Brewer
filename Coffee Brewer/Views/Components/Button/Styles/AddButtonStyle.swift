import SwiftUI

struct AddButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(BrewerColors.textPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: maxWidth)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(BrewerColors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(BrewerColors.surface, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(BrewerColors.caramel.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(14)
            .buttonPressAnimation(isPressed: configuration.isPressed)
    }
}
