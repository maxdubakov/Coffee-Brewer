import SwiftUI

struct RecipeCard: View {
    // MARK: - Public Properties
    let recipe: Recipe

    var body: some View {
        
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(BrewerColors.textPrimary.opacity(0.5))
                    .frame(width: 169, height: 169)
                    .overlay(
                        Text("⾖")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(BrewerColors.textPrimary)
                        .frame(minWidth: 99, alignment: .leading)

                    Text((recipe.lastBrewedAt ?? Date()).timeAgoDescription())
                        .font(.caption)
                        .foregroundColor(BrewerColors.textSecondary)
                        .frame(minWidth: 99, alignment: .leading)
                }
                .padding(14)
            }
            .background(BrewerColors.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 2)
        
    }
}

struct RecipeCardViewPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        @State var startedBrew = false
        
        // Create a test recipe
        let testRecipe = Recipe(context: context)
        testRecipe.name = "Ethiopian Pour Over"
        testRecipe.grams = 18
        testRecipe.ratio = 16.0
        testRecipe.waterAmount = 288
        testRecipe.temperature = 94.0
        testRecipe.grindSize = 22
        
        // Create a test roaster
        let testRoaster = Roaster(context: context)
        testRoaster.name = "Mad Heads"
        testRecipe.roaster = testRoaster
        
        // Create sample stages
        let createStage = { (type: String, water: Int16, seconds: Int16, order: Int16) in
            let stage = Stage(context: context)
            stage.type = type
            stage.waterAmount = water
            stage.seconds = seconds
            stage.orderIndex = order
            stage.recipe = testRecipe
        }
        
        // Add all three types of stages
        createStage("fast", 50, 0, 0)
        createStage("wait", 0, 30, 1)
        createStage("slow", 138, 0, 2)
        createStage("fast", 100, 0, 3)
        
        return GlobalBackground {
            RecipeCard(
                recipe: testRecipe,
            )
            .onTapGesture {
                startedBrew = true
            }
            .fullScreenCover(isPresented: $startedBrew) {
                BrewRecipeView(recipe: testRecipe)
            }
                
        }
    }
}
