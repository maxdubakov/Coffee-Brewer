import SwiftUI

struct RecipeMetricsBar: View {
    // MARK: - Properties
    var recipe: Recipe
    
    // MARK: - Computed Properties
    private var formattedTotalTime: String {
        let totalTime = getTotalTime()
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Coffee amount
            MetricCircle(
                value: "\(recipe.grams)g",
                color: BrewerColors.caramel
            )
            
            // Brew ratio
            MetricCircle(
                value: "1:\(Int(recipe.ratio))",
                color: BrewerColors.caramel
            )
            
            // Water temperature
            MetricCircle(
                value: "\(Int(recipe.temperature))°",
                color: BrewerColors.caramel
            )
            
            // Grind size
            MetricCircle(
                value: "\(recipe.grindSize)",
                color: BrewerColors.caramel
            )
            
            // Total brew time
            MetricCircle(
                value: formattedTotalTime,
                color: BrewerColors.caramel
            )
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.6))
        )
    }
    
    // MARK: - Helper Methods
    private func getTotalTime() -> Int16 {
        return recipe.stagesArray.reduce(0, {$0 + $1.seconds})
    }
}
