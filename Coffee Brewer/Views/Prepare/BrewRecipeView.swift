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
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                ZStack {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(BrewerColors.textPrimary)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        Button(action: {
                            if timerViewModel.isRunning {
                                confirmExitBrewing()
                            } else {
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                            }
                            .foregroundColor(BrewerColors.textPrimary)
                        }
                        .padding(.leading, 18)
                        
                        Spacer()
                    }
                }
                .padding(.top, 20)
                Text("by \(recipe.roaster?.name ?? "Unknown Roaster")")
                    .font(.subheadline)
                    .foregroundColor(BrewerColors.textSecondary)
                    .padding(.bottom, 24)
            }
            
            // MARK: - Recipe Metrics
            RecipeMetricsBar(recipe: recipe)
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
        
        
            VStack(spacing: 28) {
                // MARK: - Timer Circle
                BrewTimer(
                    elapsedTime: timerViewModel.elapsedTime,
                    pouredWater: timerViewModel.totalWaterPoured,
                    totalTime: timerViewModel.totalTime,
                    onToggle: timerViewModel.toggleTimer
                )
                .padding(.top, 8)
                .padding(.bottom, 30)
                
                // MARK: - Current Stage
                if let stage = currentStage {
                    CurrentStageCard(
                        stage: stage,
                        stageNumber: currentStageIndex + 1,
                        waterProgress: timerViewModel.waterPoured(forStage: currentStageIndex),
                        timeRemaining: timerViewModel.timeRemaining(forStage: currentStageIndex)
                    )
                }

                // MARK: - Next Stage
                if let stage = nextStage {
                    NextStagePreview(
                        stage: stage,
                        stageNumber: currentStageIndex + 2
                    )
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
            
            // Provide haptic feedback on stage change
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .fullScreenCover(isPresented: $showCompletionView) {
            BrewCompletionView(recipe: recipe)
        }
        .onReceive(NotificationCenter.default.publisher(for: .brewingCompleted)) { _ in
            showCompletionView = true
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
        createStage("fast", 50, 0, 0)
//        createStage("wait", 0, 30, 1)
//        createStage("slow", 138, 0, 2)
//        createStage("fast", 100, 0, 3)
        
        return GlobalBackground {
            BrewRecipeView(recipe: testRecipe)
                .environment(\.managedObjectContext, context)
        }
    }
}
