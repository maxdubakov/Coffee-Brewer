import SwiftUI
import CoreData

struct BrewRecipeView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    let recipe: Recipe
    
    // MARK: - State
    @StateObject private var timerViewModel = BrewTimerViewModel()
    @State private var currentStageIndex: Int = 0
    @State private var showCompletionView = false
    
    // MARK: - Computed Properties
    private var currentStage: Stage? {
        guard !recipe.stagesArray.isEmpty, recipe.stagesArray.count > currentStageIndex else { return nil }
        return recipe.stagesArray[currentStageIndex]
    }
    
    private var nextStage: Stage? {
        guard recipe.stagesArray.count > currentStageIndex + 1 else { return nil }
        return recipe.stagesArray[currentStageIndex + 1]
    }
    
    private var showComplete: Bool {
        timerViewModel.elapsedTime > timerViewModel.totalTime * 0.8
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            BrewTimer(
                elapsedTime: timerViewModel.elapsedTime,
                pouredWater: timerViewModel.totalWaterPoured,
                totalTime: timerViewModel.totalTime,
                onToggle: timerViewModel.toggleTimer
            ).padding(.vertical, 100)

            VStack(spacing: 30) {

                VStack {
                    RecipeMetricsBar(recipe: recipe)
                        .padding(.bottom, 20)
                    
                    // MARK: - Current Stage
                    StageScroll(recipe: recipe, timerViewModel: timerViewModel, currentStageIndex: $currentStageIndex)
                }
                
                Spacer()
                
                // MARK: - Control Buttons
                HStack(spacing: 16) {
                    // Primary action
                    StandardButton(
                        title: timerViewModel.isRunning ? "Pause" : (timerViewModel.elapsedTime > 0 ? "Resume" : "Start Brewing"),
                        action: timerViewModel.toggleTimer,
                        style: .primary
                    )

                    // Reset Button
                    if !showComplete && timerViewModel.elapsedTime > 0 {
                        StandardButton(
                            title: "Reset",
                            iconName: "arrow.counterclockwise",
                            action: {
                                timerViewModel.resetTimer()
                            },
                            style: .destructive,
                        )
                    }
                    
                    // Complete Button
                    if showComplete && timerViewModel.elapsedTime > timerViewModel.totalTime * 0.8 {
                        StandardButton(
                            title: "Complete",
                            iconName: "checkmark.circle",
                            action: {
                                completeBrew()
                            },
                            style: .secondary,
                        )
                    }
                    
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 18)
        }
        .background(BrewerColors.background.edgesIgnoringSafeArea(.all))
        .onAppear {
            timerViewModel.setupWithRecipe(recipe)
        }
        .onChange(of: timerViewModel.currentStageIndex) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentStageIndex = newValue
            }

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .fullScreenCover(isPresented: $showCompletionView) {
            GlobalBackground {
                BrewCompletionView(recipe: recipe)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .brewingCompleted)) { _ in
            showCompletionView = true
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 5) {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                    Text(recipe.roaster?.name ?? "Unknown Roaster")
                        .font(.subheadline)
                        .foregroundColor(BrewerColors.textSecondary)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Methods
    private func confirmExitBrewing() {
        // In a real implementation, you'd use a proper SwiftUI confirmation dialog
        timerViewModel.stopTimer()
        dismiss()
    }
    
    private func completeBrew() {
        // Stop the timer
        timerViewModel.stopTimer()
        
        // Save brew to history
        recipe.lastBrewedAt = Date()
        do {
            try viewContext.save()
        } catch {
            print("Error saving brew date: \(error)")
        }
        
        // Show completion screen
        showCompletionView = true
    }
}

// MARK: - Extensions
private extension BrewTimerViewModel {
    func stopTimer() {
        isRunning = false
        // This calls the internal timer cancel logic
        toggleTimer()
    }
}

// MARK: - Preview
struct BrewRecipeViewPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
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
        createStage("fast", 50, 15, 0)
        createStage("wait", 0, 30, 1)
        createStage("slow", 138, 15, 2)
        createStage("fast", 100, 40, 3)
        
        return GlobalBackground {
            BrewRecipeView(recipe: testRecipe)
                .environment(\.managedObjectContext, context)
        }
    }
}
