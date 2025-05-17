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
        GeometryReader { geometry in
            HStack(spacing: calculateSpacing(for: geometry.size.width)) {
                RecipeMetric(
                    iconName: "scalemass",
                    value: "\(recipe.grams)g",
                    color: BrewerColors.caramel
                )
                
                RecipeMetric(
                    iconName: "drop",
                    value: "\(recipe.waterAmount)ml",
                    color: BrewerColors.caramel
                )
                
                RecipeMetric(
                    iconName: "equal.square",
                    value: "1:\(Int(recipe.ratio))",
                    color: BrewerColors.caramel
                )
                
                RecipeMetric(
                    iconName: "thermometer",
                    value: "\(Int(recipe.temperature))°",
                    color: BrewerColors.caramel
                )
                
                RecipeMetric(
                    iconName: "circle.grid.3x3",
                    value: "\(recipe.grindSize)",
                    color: BrewerColors.caramel
                )
                
                RecipeMetric(
                    iconName: "timer",
                    value: formattedTotalTime,
                    color: BrewerColors.caramel
                )
            }
            .frame(width: geometry.size.width)
        }
        .frame(height: 35) // Fixed height for the container
    }
    
    private func calculateSpacing(for width: CGFloat) -> CGFloat {
        // Adaptive spacing based on screen width
        // This is a simple approach - you may need to fine-tune
        if width < 330 { // Small iPhone (SE, mini)
            return 2
        } else if width < 380 { // Medium iPhone (base models)
            return 4
        } else { // Larger iPhones (Plus, Pro Max)
            return 6
        }
    }
    
    private func getTotalTime() -> Int16 {
        return recipe.stagesArray.reduce(0, {$0 + $1.seconds})
    }
}
