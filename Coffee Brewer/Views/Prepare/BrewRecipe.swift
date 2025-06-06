import SwiftUI
import CoreData

struct BrewRecipe: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
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
                
                VStack(spacing: 24) {
                    // MARK: - Brew Control Panel
                    BrewControlPanel(
                        isRunning: Binding(
                            get: { timerViewModel.isRunning },
                            set: { newValue in
                                if newValue != timerViewModel.isRunning {
                                    timerViewModel.toggleTimer()
                                }
                            }
                        ),
                        currentStageIndex: $currentStageIndex,
                        totalStages: recipe.stagesArray.count,
                        onTogglePlay: timerViewModel.toggleTimer,
                        onRestart: {
                            timerViewModel.resetTimer()
                            currentStageIndex = 0
                        },
                        onSkipForward: {
                            skipToStage(currentStageIndex + 1)
                        },
                        onSkipBackward: {
                            skipToStage(currentStageIndex - 1)
                        }
                    )
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
        .onChange(of: currentStageIndex) { oldValue, newValue in
            if timerViewModel.currentStageIndex != newValue {
                skipToStage(newValue)
            }
        }
        .sheet(isPresented: $showCompletionView) {
            GlobalBackground {
                if let brewId = timerViewModel.savedBrewId,
                   let brew = fetchBrew(withId: brewId) {
                    BrewCompletion(brew: brew)
                        .environmentObject(navigationCoordinator)
                } else {
                    // Fallback to old behavior if brew wasn't saved
                    BrewCompletion(recipe: recipe, actualElapsedTime: timerViewModel.elapsedTime)
                        .environmentObject(navigationCoordinator)
                }
            }
            .interactiveDismissDisabled()
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
    private func fetchBrew(withId id: UUID) -> Brew? {
        let request: NSFetchRequest<Brew> = Brew.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let brews = try viewContext.fetch(request)
            return brews.first
        } catch {
            print("Failed to fetch brew: \(error)")
            return nil
        }
    }
    
    private func skipToStage(_ targetIndex: Int) {
        guard targetIndex >= 0 && targetIndex < recipe.stagesArray.count else { return }
        
        timerViewModel.stopTimer()
        
        timerViewModel.skipToStage(targetIndex)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentStageIndex = targetIndex
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func confirmExitBrewing() {
        timerViewModel.stopTimer()
        dismiss()
    }
    
    private func completeBrew() {
        timerViewModel.stopTimer()
        showCompletionView = true
    }
}

extension Notification.Name {
    static let brewingCompleted = Notification.Name("brewingCompleted")
}

// MARK: - Preview
struct BrewRecipePreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let testRecipe = Recipe(context: context)
        testRecipe.id = UUID()
        testRecipe.name = "Ethiopian Pour Over"
        testRecipe.grams = 18
        testRecipe.ratio = 16.0
        testRecipe.waterAmount = 288
        testRecipe.temperature = 94.0
        testRecipe.grindSize = 22
        
        let testRoaster = Roaster(context: context)
        testRoaster.id = UUID()
        testRoaster.name = "Mad Heads"
        testRecipe.roaster = testRoaster
        
        let createStage = { (type: String, water: Int16, seconds: Int16, order: Int16) in
            let stage = Stage(context: context)
            stage.id = UUID()
            stage.type = type
            stage.waterAmount = water
            stage.seconds = seconds
            stage.orderIndex = order
            stage.recipe = testRecipe
        }
        
        createStage("fast", 50, 2, 0)
//        createStage("wait", 0, 30, 1)
//        createStage("slow", 138, 15, 2)
//        createStage("fast", 100, 40, 3)
        
        return GlobalBackground {
            BrewRecipe(recipe: testRecipe)
                .environment(\.managedObjectContext, context)
        }
    }
}
