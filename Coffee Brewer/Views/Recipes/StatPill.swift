import SwiftUI

struct StatPill: View {
    var title: String
    var icon: String
    var color: Color = BrewerColors.caramel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(BrewerColors.textPrimary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(red: 0.15, green: 0.13, blue: 0.11))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(color.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
