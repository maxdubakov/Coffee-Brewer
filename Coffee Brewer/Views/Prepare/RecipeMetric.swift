import SwiftUI

struct RecipeMetric: View {
    var iconName: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            // Icon section
            Image(systemName: iconName)
                .font(.system(size: 10))
                .foregroundColor(color)
                .frame(width: 12, height: 12)
            
            // Value
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(BrewerColors.textPrimary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(BrewerColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
