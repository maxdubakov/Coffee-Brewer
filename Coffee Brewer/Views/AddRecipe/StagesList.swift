import SwiftUI

struct StagesList: View {
    // MARK: - Properties
    @ObservedObject var recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(recipe.stagesArray.enumerated()), id: \.element) { index, stage in
                StageView(stage: stage, stageNumber: index + 1, progressValue: recipe.totalStageWaterToStep(stepIndex: index))
            }
            AddButton(
                title: "Add Stage",
                action: {},
            )
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create a sample recipe with all stage types
    let recipe = Recipe(context: context)
    recipe.name = "Ethiopian Pour Over"
    recipe.grams = 18
    recipe.ratio = 16.0
    recipe.waterAmount = 288
    recipe.temperature = 94.0
    
    // Helper function to create stages
    func createStage(type: String, water: Int16 = 0, seconds: Int16 = 0, order: Int16) {
        let stage = Stage(context: context)
        stage.type = type
        stage.waterAmount = water
        stage.seconds = seconds
        stage.orderIndex = order
        stage.recipe = recipe
    }
    
    // Add all three types of stages
    createStage(type: "fast", water: 50, order: 0)
    createStage(type: "wait", seconds: 30, order: 1)
    createStage(type: "slow", water: 138, order: 2)
    createStage(type: "fast", water: 100, order: 3)
    
    return ZStack {
        BrewerColors.background.edgesIgnoringSafeArea(.all)
        
        VStack(alignment: .leading) {
            Text("Stages")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .padding(.bottom, 10)
            
            StagesList(recipe: recipe)
        }
        .padding()
    }
}
