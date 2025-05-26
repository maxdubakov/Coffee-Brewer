import SwiftUI
import Combine

@MainActor
class RecordStagesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elapsedTime: Double = 0
    @Published var isRunning: Bool = false
    @Published var recordedTimestamps: [(time: Double, id: UUID, type: StageType)] = []
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private let formData: RecipeFormData
    private let brewMath: BrewMathViewModel
    
    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel) {
        self.formData = formData
        self.brewMath = brewMath
    }
    
    // MARK: - Public Methods
    func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func recordTap(type: StageType = .slow) {
        let timestamp = (time: elapsedTime, id: UUID(), type: type)
        recordedTimestamps.append(timestamp)
    }
    
    func removeTimestamp(at index: Int) {
        guard index < recordedTimestamps.count else { return }
        recordedTimestamps.remove(at: index)
    }
    
    func resetRecording() {
        stopTimer()
        elapsedTime = 0
        recordedTimestamps.removeAll()
    }
    
    func generateStagesFromTimestamps() -> [StageFormData] {
        var stages: [StageFormData] = []
        var previousTime: Double = 0
        
        for (index, timestamp) in recordedTimestamps.enumerated() {
            var stage = StageFormData()
            stage.orderIndex = Int16(index)
            stage.seconds = Int16(timestamp.time - previousTime)
            stage.type = timestamp.type
            
            // Calculate water amount proportionally (only for pour stages)
            if timestamp.type != .wait {
                let timeRatio = (timestamp.time - previousTime) / elapsedTime
                stage.waterAmount = Int16(Double(brewMath.water) * timeRatio)
            } else {
                stage.waterAmount = 0
            }
            
            stages.append(stage)
            previousTime = timestamp.time
        }
        
        // Adjust water amounts to match total
        adjustWaterAmounts(for: &stages)
        
        return stages
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime += 0.1
            }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    private func adjustWaterAmounts(for stages: inout [StageFormData]) {
        let totalWater = brewMath.water
        let currentTotal = stages.reduce(0) { $0 + $1.waterAmount }
        
        guard currentTotal > 0 else { return }
        
        // Adjust each stage proportionally
        let adjustmentRatio = Double(totalWater) / Double(currentTotal)
        
        var runningTotal: Int16 = 0
        for i in 0..<stages.count {
            if i == stages.count - 1 {
                // Last stage gets the remainder to ensure exact match
                stages[i].waterAmount = totalWater - runningTotal
            } else {
                stages[i].waterAmount = Int16(Double(stages[i].waterAmount) * adjustmentRatio)
                runningTotal += stages[i].waterAmount
            }
        }
    }
}