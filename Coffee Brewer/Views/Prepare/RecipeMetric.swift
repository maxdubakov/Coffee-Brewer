import SwiftUI

struct RecipeMetric: View {
    var iconName: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            // Icon section
            Image(systemName: iconName)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 16, height: 16)
            
            // Value
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(BrewerColors.textPrimary)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(BrewerColors.surface.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}
