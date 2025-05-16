import SwiftUI
import CoreData

struct StagesList: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Bindings
    @Binding var focusedField: AddRecipe.FocusedField?
    
    // MARK: - Observed Objects
    @ObservedObject var recipe: Recipe
    @ObservedObject var brewMath: BrewMathViewModel
    
    // MARK: - State
    @State private var isAddingStage = false
    @State private var isModifyingStage = false

    // Animation state
    @State private var stageOpacity: [NSManagedObjectID: Double] = [:]
    @State private var stageHeight: [NSManagedObjectID: CGFloat] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(recipe.stagesArray.enumerated()), id: \.element.objectID) { index, stage in
                StageView(
                    stage: stage,
                    stageNumber: index + 1,
                    progressValue: recipe.totalStageWaterToStep(stepIndex: index),
                    onDelete: {
                        deleteStageWithAnimation(stage)
                    }
                )
                .opacity(stageOpacity[stage.objectID] ?? 1.0)
                .frame(height: stageHeight[stage.objectID] ?? nil)
                .onTapGesture {
                    isModifyingStage = true
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
                .fullScreenCover(isPresented: $isModifyingStage) {
                    GlobalBackground {
                        AddStageView(
                            recipe: recipe,
                            brewMath: brewMath,
                            focusedField: $focusedField,
                            existingStage: stage
                        )
                        
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: recipe.stagesArray.count)
            
            AddButton(
                title: "Add Stage",
                action: {
                    isAddingStage = true
                },
            )
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.4), value: isAddingStage)
        }
        .fullScreenCover(isPresented: $isAddingStage) {
            GlobalBackground {
                AddStageView(recipe: recipe, brewMath: brewMath, focusedField: $focusedField)
            }
        }
        .onAppear {
            // Initialize animation states for all stages
            for stage in recipe.stagesArray {
                if stageOpacity[stage.objectID] == nil {
                    stageOpacity[stage.objectID] = 1.0
                    stageHeight[stage.objectID] = nil
                }
            }
        }
    }
    
    // MARK: - Methods
    private func deleteStageWithAnimation(_ stage: Stage) {
        withAnimation(.easeInOut(duration: 0.3)) {
            stageOpacity[stage.objectID] = 0.0
            stageHeight[stage.objectID] = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewContext.delete(stage)
            
            // Reindex remaining stages
            let remainingStages = recipe.stagesArray
            for (index, remainingStage) in remainingStages.enumerated() {
                remainingStage.orderIndex = Int16(index)
            }

            withAnimation {
                do {
                    try viewContext.save()
                    
                    // Clean up our animation state dictionaries
                    stageOpacity.removeValue(forKey: stage.objectID)
                    stageHeight.removeValue(forKey: stage.objectID)
                } catch {
                    print("Failed to delete stage: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext

    var brewMath = BrewMathViewModel(
        grams: 18,
        ratio: 16.0,
        water: 288
    )
    
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
            
            StagesList(focusedField: .constant(nil), recipe: recipe, brewMath: brewMath)
        }
        .padding()
    }
}
