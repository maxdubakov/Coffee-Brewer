import SwiftUI

struct WaterBalanceIndicator: View {
    let currentWater: Int16
    let totalWater: Int16
    
    private var isBalanced: Bool {
        currentWater == totalWater
    }
    
    private var percentFilled: CGFloat {
        if totalWater == 0 { return 0 }
        return min(1.0, CGFloat(currentWater) / CGFloat(totalWater))
    }
    
    private var statusColor: Color {
        if isBalanced {
            return BrewerColors.caramel
        } else if currentWater > totalWater {
            return Color.red
        } else {
            return BrewerColors.amber
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Water drop icon with coffee-themed style
            ZStack {
                Circle()
                    .fill(BrewerColors.surface)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 12))
                    .foregroundColor(statusColor)
            }
            
            // Progress bar with coffee gradient
            ZStack(alignment: .leading) {
                // Empty container
                Capsule()
                    .fill(BrewerColors.surface)
                    .frame(height: 6)
                
                // Filled portion with subtle gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [statusColor.opacity(0.7), statusColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(4, percentFilled * 80), height: 6)
            }
            .frame(width: 80)
            
            // Water values with dynamic color
            Text("\(currentWater)/\(totalWater) ml")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isBalanced ? BrewerColors.textSecondary : statusColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(BrewerColors.surface.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(statusColor.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}
