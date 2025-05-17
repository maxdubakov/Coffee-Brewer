import SwiftUI

struct RecipeMetricsBar: View {
    var recipe: Recipe

    private var formattedTotalTime: String {
        let totalTime = getTotalTime()
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                RecipeMetric(iconName: "scalemass", value: "\(recipe.grams)g", color: BrewerColors.caramel)
                
                RecipeMetric(iconName: "drop", value: "\(recipe.waterAmount)ml", color: BrewerColors.caramel)
                
                RecipeMetric(iconName: "equal.square", value: "1:\(Int(recipe.ratio))", color: BrewerColors.caramel)
            }

            HStack {
                RecipeMetric(iconName: "thermometer", value: "\(Int(recipe.temperature))°", color: BrewerColors.caramel)
                
                RecipeMetric(iconName: "circle.grid.3x3", value: "\(recipe.grindSize)", color: BrewerColors.caramel)
                
                RecipeMetric(iconName: "timer", value: formattedTotalTime, color: BrewerColors.caramel)
            }
        }
    }

    private func getTotalTime() -> Int16 {
        recipe.stagesArray.reduce(0) { $0 + $1.seconds }
    }
}
