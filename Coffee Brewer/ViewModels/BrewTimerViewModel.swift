import SwiftUI
import CoreData
import Combine

class BrewTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elapsedTime: Double = 0
    @Published var totalTime: Double = 0
    @Published var isRunning: Bool = false
    @Published var currentStageIndex: Int = 0
    @Published var totalWaterPoured: Int16 = 0
    @Published var stageElapsedTimes: [Double] = []
    @Published var stageProgress: [Double] = []
    @Published var savedBrewId: UUID?
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var stageDurations: [Double] = []
    private var stageWaterAmounts: [Int16] = []
    private var recipe: Recipe?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    func setupWithRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        calculateStageDurations(recipe)
        calculateTotalTime()
        calculateStageWaterAmounts(recipe)
        stageElapsedTimes = Array(repeating: 0.0, count: recipe.stagesArray.count)
        stageProgress = Array(repeating: 0.0, count: recipe.stagesArray.count)
    }
    
    func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func resetTimer() {
        stopTimer()

        elapsedTime = 0
        stageElapsedTimes = Array(repeating: 0.0, count: stageElapsedTimes.count)
        stageProgress = Array(repeating: 0.0, count: stageProgress.count)
        currentStageIndex = 0
        totalWaterPoured = 0
    }
    
    func skipToStage(_ index: Int) {
        guard let recipe = recipe, index >= 0, index < recipe.stagesArray.count else { return }
        
        if index > currentStageIndex {
            // First subtract any partially poured water from current stage
            if currentStageIndex < recipe.stagesArray.count {
                let currentStage = recipe.stagesArray[currentStageIndex]
                if currentStage.type != "wait" {
                    // Calculate how much water was already poured for the current stage
                    let currentStagePartialWater = Int16(Double(currentStage.waterAmount) * stageProgress[currentStageIndex])
                    
                    // Remove this partial amount (it will be replaced with the full amount)
                    totalWaterPoured -= currentStagePartialWater
                }
            }
            
            // Moving forward: add all the water from skipped stages
            for i in currentStageIndex..<index {
                let stage = recipe.stagesArray[i]
                if stage.type != "wait" {
                    totalWaterPoured += stage.waterAmount
                }
                
                // Mark these stages as complete in progress array
                stageProgress[i] = 1.0
                stageElapsedTimes[i] = stageDurations[i]
            }
        } else if index < currentStageIndex {
            // Moving backward: recalculate total water from scratch
            totalWaterPoured = 0
            
            // Reset progress for stages we're moving back past
            for i in 0..<stageElapsedTimes.count {
                if i >= index {
                    // Reset stages we're moving back to or past
                    stageElapsedTimes[i] = 0.0
                    stageProgress[i] = 0.0
                } else {
                    // Earlier stages remain complete
                    stageElapsedTimes[i] = stageDurations[i]
                    stageProgress[i] = 1.0
                    
                    // Add water for completed earlier stages
                    let stage = recipe.stagesArray[i]
                    if stage.type != "wait" {
                        totalWaterPoured += stage.waterAmount
                    }
                }
            }
        }

        currentStageIndex = index
    }
    

    func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    

    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let recipe = self.recipe else { return }
                
                if self.currentStageIndex < self.stageElapsedTimes.count {
                    self.stageElapsedTimes[self.currentStageIndex] += 0.1
                    
                    if self.stageDurations[self.currentStageIndex] > 0 {
                        self.stageProgress[self.currentStageIndex] = min(1.0,
                            self.stageElapsedTimes[self.currentStageIndex] /
                            self.stageDurations[self.currentStageIndex])
                    }
                }
                
                self.elapsedTime += 0.1
                
                if self.stageElapsedTimes[self.currentStageIndex] >= self.stageDurations[self.currentStageIndex] {
                    self.completeCurrentStage()
                }
                
                self.updateWaterAmount()
                
                if self.currentStageIndex >= recipe.stagesArray.count {
                    self.completeBrewingProcess()
                }
            }
    }
    
    func progressForStage(_ index: Int) -> Double {
        guard index < stageProgress.count else { return 0 }
        return stageProgress[index]
    }
    
    // MARK: - Private Methods
    private func completeCurrentStage() {
        guard let recipe = recipe, currentStageIndex < recipe.stagesArray.count else { return }
        
        stageElapsedTimes[currentStageIndex] = stageDurations[currentStageIndex]
        stageProgress[currentStageIndex] = 1.0
        
        if currentStageIndex + 1 < recipe.stagesArray.count {
            currentStageIndex += 1
        } else {
            completeBrewingProcess()
        }
    }
    
    private func updateWaterAmount() {
        guard let recipe = recipe, currentStageIndex < recipe.stagesArray.count else { return }
        
        var totalWater: Int16 = 0
        
        // Calculate water from all completed stages
        for i in 0..<currentStageIndex {
            let completedStage = recipe.stagesArray[i]
            if completedStage.type != "wait" {
                totalWater += completedStage.waterAmount
            }
        }
        
        // Add water from current stage if it's not a wait stage
        let stage = recipe.stagesArray[currentStageIndex]
        if stage.type != "wait" {
            let stageProgress = progressForStage(currentStageIndex)
            let currentStageWater = Int16(Double(stage.waterAmount) * stageProgress)
            totalWater += currentStageWater
        }
        
        totalWaterPoured = totalWater
    }
    
    private func calculateStageDurations(_ recipe: Recipe) {
        stageDurations = recipe.stagesArray.map { Double($0.seconds) }
        
        for (index, stage) in recipe.stagesArray.enumerated() {
            if stage.type != "wait" && stageDurations[index] <= 0 {
                stageDurations[index] = 30.0
            }
        }
    }
    
    private func calculateTotalTime() {
        totalTime = stageDurations.reduce(0, +)
    }
    
    private func calculateStageWaterAmounts(_ recipe: Recipe) {
        stageWaterAmounts = recipe.stagesArray.map { $0.waterAmount }
    }
    
    private func completeBrewingProcess() {
        stopTimer()
        
        // Save the brew immediately with basic data
        if let recipe = recipe {
            saveBrew(recipe: recipe)
        }
        
        NotificationCenter.default.post(name: .brewingCompleted, object: nil)
    }
    
    private func saveBrew(recipe: Recipe) {
        guard let context = recipe.managedObjectContext else { return }
        
        let brew = Brew(context: context)
        let brewId = UUID()
        brew.id = brewId
        brew.date = Date()
        brew.actualDurationSeconds = Int16(elapsedTime)
        brew.recipe = recipe
        brew.isAssessed = false
        
        // Copy recipe data for historical preservation
        brew.recipeName = recipe.name
        brew.recipeGrams = recipe.grams
        brew.recipeWaterAmount = recipe.waterAmount
        brew.recipeRatio = recipe.ratio
        brew.recipeTemperature = recipe.temperature
        brew.recipeGrindSize = recipe.grindSize
        brew.roasterName = recipe.roaster?.name
        brew.grinderName = recipe.grinder?.name
        
        // Update recipe's last brewed date
        recipe.lastBrewedAt = Date()
        
        do {
            try context.save()
            savedBrewId = brewId
        } catch {
            print("Failed to save brew: \(error)")
        }
    }
}
