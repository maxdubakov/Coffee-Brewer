import SwiftUI
import Combine

@MainActor
class RecordStagesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elapsedTime: Double = 0
    @Published var isRunning: Bool = false
    @Published var recordedTimestamps: [(time: Double, id: UUID, type: StageType)] = []
    @Published var activeRecording: (type: StageType, startTime: Double)? = nil
    @Published var hasStartedRecording: Bool = false
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private let formData: RecipeFormData
    private let brewMath: BrewMathViewModel
    private var lastRecordedTime: Double = 0
    
    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel) {
        self.formData = formData
        self.brewMath = brewMath
    }
    
    // MARK: - Computed Properties
    var willAddFinalWaitStage: Bool {
        guard !recordedTimestamps.isEmpty else { return false }
        let lastRecordedTime = recordedTimestamps.last?.time ?? 0
        return elapsedTime - lastRecordedTime > 1.0
    }
    
    var finalWaitDuration: Double {
        guard willAddFinalWaitStage else { return 0 }
        let lastRecordedTime = recordedTimestamps.last?.time ?? 0
        return elapsedTime - lastRecordedTime
    }
    
    // Combined timestamps including active recording and final wait
    var displayTimestamps: [(time: Double, id: UUID, type: StageType, isActive: Bool)] {
        var timestamps = recordedTimestamps.map { (time: $0.time, id: $0.id, type: $0.type, isActive: false) }
        
        if let active = activeRecording {
            let activeTimestamp = (time: elapsedTime, id: UUID(), type: active.type, isActive: true)
            timestamps.append(activeTimestamp)
        } else if !recordedTimestamps.isEmpty && elapsedTime > lastRecordedTime {
            // Show final wait stage when no active recording
            let finalWaitTimestamp = (time: elapsedTime, id: UUID(), type: StageType.wait, isActive: true)
            timestamps.append(finalWaitTimestamp)
        }
        
        return timestamps
    }
    
    // MARK: - Public Methods
    func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func startRecording(type: StageType) {
        // Mark that recording has started
        hasStartedRecording = true
        
        // Start timer if not already running
        if !isRunning {
            startTimer()
        }
        
        // Add a wait stage if there's a gap since last recording
        if !recordedTimestamps.isEmpty && elapsedTime > lastRecordedTime {
            let waitTimestamp = (time: elapsedTime, id: UUID(), type: StageType.wait)
            recordedTimestamps.append(waitTimestamp)
        }
        
        activeRecording = (type: type, startTime: elapsedTime)
    }
    
    func confirmRecording() {
        guard let active = activeRecording else { return }
        
        let timestamp = (time: elapsedTime, id: UUID(), type: active.type)
        recordedTimestamps.append(timestamp)
        lastRecordedTime = elapsedTime
        activeRecording = nil
    }
    
    func cancelRecording() {
        activeRecording = nil
    }
    
    func removeTimestamp(at index: Int) {
        guard index < recordedTimestamps.count else { return }
        recordedTimestamps.remove(at: index)
    }
    
    func resetRecording() {
        stopTimer()
        elapsedTime = 0
        recordedTimestamps.removeAll()
        activeRecording = nil
        lastRecordedTime = 0
        hasStartedRecording = false
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
        
        // Add a final wait stage if there's time remaining after the last recorded timestamp
        if !recordedTimestamps.isEmpty && elapsedTime > previousTime {
            let finalWaitTime = elapsedTime - previousTime
            if finalWaitTime > 1.0 { // Only add if wait is more than 1 second
                var finalWaitStage = StageFormData()
                finalWaitStage.orderIndex = Int16(stages.count)
                finalWaitStage.seconds = Int16(finalWaitTime)
                finalWaitStage.type = .wait
                finalWaitStage.waterAmount = 0
                stages.append(finalWaitStage)
            }
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