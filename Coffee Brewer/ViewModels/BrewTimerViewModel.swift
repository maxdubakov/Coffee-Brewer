import SwiftUI
import Combine

class BrewTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elapsedTime: Double = 0
    @Published var totalTime: Double = 0
    @Published var isRunning: Bool = false
    @Published var currentStageIndex: Int = 0
    @Published var totalWaterPoured: Int16 = 0
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var stageTimes: [Double] = []
    private var stageWaterAmounts: [Int16] = []
    private var recipe: Recipe?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    func setupWithRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        calculateStageTimes(recipe)
        calculateTotalTime()
        calculateStageWaterAmounts(recipe)
    }
    
    func toggleTimer() {
        isRunning.toggle()
        
        if isRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        currentStageIndex = 0
        totalWaterPoured = 0
    }
    
    func advanceToNextStage() {
        guard let recipe = recipe else { return }
        
        if currentStageIndex < recipe.stagesArray.count - 1 {
            // Update water poured for current stage if needed
            if recipe.stagesArray[currentStageIndex].type != "wait" {
                totalWaterPoured += recipe.stagesArray[currentStageIndex].waterAmount
            }
            
            // Advance to next stage
            currentStageIndex += 1
        } else {
            // Brewing complete - handle completion
            completeBrewingProcess()
        }
    }
    
    func waterPoured(forStage stageIndex: Int) -> Double {
        guard let recipe = recipe, stageIndex < recipe.stagesArray.count else { return 0 }
        
        let stage = recipe.stagesArray[stageIndex]
        if stage.type == "wait" { return 1.0 } // Wait stages are complete or not
        
        if stageIndex < currentStageIndex {
            // Previous stages have completed their water
            return 1.0
        } else if stageIndex > currentStageIndex {
            // Future stages haven't started
            return 0.0
        } else {
            // Current stage - calculate based on time
            let stageStartTime = stageStartTime(forStage: stageIndex)
            let stageDuration = stageDuration(forStage: stageIndex)
            
            if stageDuration <= 0 { return 0 }
            
            let stageElapsedTime = max(0, min(stageDuration, elapsedTime - stageStartTime))
            return stageElapsedTime / stageDuration
        }
    }
    
    func timeRemaining(forStage stageIndex: Int) -> Double {
        guard stageIndex < stageTimes.count else { return 0 }
        
        let stageStartTime = stageStartTime(forStage: stageIndex)
        let stageDuration = stageDuration(forStage: stageIndex)
        
        if elapsedTime < stageStartTime {
            // Stage hasn't started yet
            return stageDuration
        } else {
            // Stage is in progress
            return max(0, stageDuration - (elapsedTime - stageStartTime))
        }
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.elapsedTime += 0.1
                self.updateCurrentStage()
                self.updateWaterAmount()
                
                // Check if brewing is complete
                if self.elapsedTime >= self.totalTime {
                    self.completeBrewingProcess()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateCurrentStage() {
        guard let recipe = recipe else { return }
        
        for (index, _) in recipe.stagesArray.enumerated() {
            let stageStart = stageStartTime(forStage: index)
            let stageEnd = stageStart + stageDuration(forStage: index)
            
            if elapsedTime >= stageStart && elapsedTime < stageEnd {
                if currentStageIndex != index {
                    currentStageIndex = index
                }
                return
            }
        }
    }
    
    private func updateWaterAmount() {
        guard let recipe = recipe else { return }
        
        var newWaterAmount: Int16 = 0
        
        for (index, stage) in recipe.stagesArray.enumerated() {
            if stage.type == "wait" { continue }
            
            if index < currentStageIndex {
                // Prior stages have completed their water
                newWaterAmount += stage.waterAmount
            } else if index == currentStageIndex {
                // Current stage - calculate partial water based on stage progress
                let stageProgress = waterPoured(forStage: index)
                newWaterAmount += Int16(Double(stage.waterAmount) * stageProgress)
            }
        }
        
        totalWaterPoured = newWaterAmount
    }
    
    private func calculateStageTimes(_ recipe: Recipe) {
        stageTimes = []
        var currentTime: Double = 0
        
        for stage in recipe.stagesArray {
            var stageDuration: Double = 0
            
            switch stage.type {
            case "fast":
                // Fast pour - estimate 15 seconds per 100ml
                stageDuration = Double(stage.waterAmount) * 0.15
            case "slow":
                // Slow pour - estimate 30 seconds per 100ml
                stageDuration = Double(stage.waterAmount) * 0.3
            case "wait":
                // Wait stage - use the specified seconds
                stageDuration = Double(stage.seconds)
            default:
                stageDuration = 0
            }
            
            stageTimes.append(currentTime)
            currentTime += stageDuration
        }
    }
    
    private func calculateTotalTime() {
        guard let _ = recipe, !stageTimes.isEmpty else {
            totalTime = 0
            return
        }
        
        if let lastIndex = stageTimes.indices.last {
            totalTime = stageTimes[lastIndex] + stageDuration(forStage: lastIndex)
        }
    }
    
    private func calculateStageWaterAmounts(_ recipe: Recipe) {
        stageWaterAmounts = recipe.stagesArray.map { $0.waterAmount }
    }
    
    private func stageStartTime(forStage index: Int) -> Double {
        guard index < stageTimes.count else { return 0 }
        return stageTimes[index]
    }
    
    private func stageDuration(forStage index: Int) -> Double {
        guard let recipe = recipe, index < recipe.stagesArray.count else { return 0 }
        
        let stage = recipe.stagesArray[index]
        
        switch stage.type {
        case "fast":
            return Double(stage.waterAmount) * 0.15
        case "slow":
            return Double(stage.waterAmount) * 0.3
        case "wait":
            return Double(stage.seconds)
        default:
            return 0
        }
    }
    
    private func completeBrewingProcess() {
        // Stop the timer
        stopTimer()
        
        // Save the brew to history if needed
        saveBrewToHistory()
        
        // Notify UI that brewing is complete
        NotificationCenter.default.post(name: .brewingCompleted, object: nil)
    }
    
    private func saveBrewToHistory() {
        guard let recipe = recipe else { return }
        
        // Update the last brewed date
        recipe.lastBrewedAt = Date()
        
        // Save to Core Data
        if let context = recipe.managedObjectContext {
            do {
                try context.save()
            } catch {
                print("Error saving brew history: \(error)")
            }
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let brewingCompleted = Notification.Name("brewingCompleted")
}
