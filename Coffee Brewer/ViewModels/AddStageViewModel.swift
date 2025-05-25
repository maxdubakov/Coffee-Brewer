import SwiftUI
import CoreData
import Combine

@MainActor
class AddStageViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedType: StageType = .fast
    @Published var seconds: Int16 = 15
    @Published var waterAmount: Int16 = 0
    @Published var showSaveError = false
    @Published var errorMessage = ""
    @Published var focusedField: FocusedField?
    
    // MARK: - Private Properties
    private let stagesViewModel: StagesManagementViewModel
    private let existingStage: StageFormData?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isEditMode: Bool {
        existingStage != nil
    }
    
    var headerTitle: String {
        isEditMode ? "Edit Stage" : "Add Stage"
    }
    
    var headerSubtitle: String {
        "Select the type of brewing stage and define its parameters"
    }
    
    var actionButtonTitle: String {
        isEditMode ? "Update Stage" : "Save Stage"
    }
    
    var totalWaterUsed: Int16 {
        var amount = stagesViewModel.formData.stages.reduce(0) { $0 + $1.waterAmount }
        if isEditMode {
            amount -= existingStage?.waterAmount ?? 0
        }
        return amount
    }
    
    var remainingWater: Int16 {
        stagesViewModel.brewMath.water - totalWaterUsed
    }
    
    var availableWater: Int16 {
        remainingWater
    }
    
    var canSave: Bool {
        if selectedType == .wait {
            return seconds > 0
        } else {
            return waterAmount > 0 && waterAmount <= availableWater
        }
    }
    
    var recipeWaterAmount: Int16 {
        stagesViewModel.formData.waterAmount
    }
    
    var stageTypeDescription: String {
        switch selectedType.id {
        case "fast":
            return "Fast Pour: Quick addition of water, typically used for the bloom or to rapidly add water."
        case "slow":
            return "Slow Pour: Gradual addition of water, typically in a circular motion to extract flavor evenly."
        case "wait":
            return "Wait: Pause brewing to allow extraction, typically after bloom or between pours."
        default:
            return ""
        }
    }
    
    var durationDescription: String {
        if selectedType == .wait {
            return "How long to wait before proceeding"
        } else {
            return "How long to pour the water"
        }
    }
    
    var waterDescription: String {
        "Amount of water to pour during this stage"
    }
    
    var previewDescription: String {
        switch selectedType {
        case .fast:
            return "Pour \(waterAmount)ml in \(seconds) seconds"
        case .slow:
            return "Pour \(waterAmount)ml slowly over \(seconds) seconds"
        case .wait:
            return "Wait for \(seconds) seconds"
        default:
            return ""
        }
    }
    
    var showWaterSection: Bool {
        selectedType != .wait
    }
    
    var availableWaterText: String {
        "Available: \(availableWater)ml"
    }
    
    var availableWaterColor: Color {
        if waterAmount > availableWater {
            return .red
        } else if availableWater < 50 {
            return .orange
        } else {
            return BrewerColors.textSecondary
        }
    }
    
    var useAllButtonEnabled: Bool {
        availableWater > 0 && waterAmount != availableWater
    }
    
    // MARK: - Initialization
    init(stagesViewModel: StagesManagementViewModel, existingStage: StageFormData? = nil) {
        self.stagesViewModel = stagesViewModel
        self.existingStage = existingStage
        
        if let stage = existingStage {
            self.selectedType = stage.type
            self.seconds = stage.seconds
            self.waterAmount = stage.waterAmount
        } else {
            // Set smart defaults for new stage
            initializeSmartDefaults()
        }
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func saveStage() {
        guard canSave else {
            if selectedType == .wait && seconds <= 0 {
                errorMessage = "Please set a wait duration"
            } else if waterAmount <= 0 {
                errorMessage = "Please enter a water amount"
            } else if waterAmount > availableWater {
                errorMessage = "Water amount exceeds available water (\(availableWater)ml)"
            }
            showSaveError = true
            return
        }
        
        var stageData = existingStage ?? StageFormData()
        stageData.type = selectedType
        stageData.seconds = seconds
        stageData.waterAmount = selectedType == .wait ? 0 : waterAmount
        
        if isEditMode {
            stagesViewModel.updateStage(stageData)
        } else {
            stagesViewModel.addStage(stageData)
        }
    }
    
    func saveOrUpdateStage(completion: @escaping (Bool) -> Void) {
        saveStage()
        completion(!showSaveError)
    }
    
    func useAllWater() {
        waterAmount = availableWater
    }
    
    func createPreviewStage() -> StageFormData {
        var preview = existingStage ?? StageFormData()
        preview.type = selectedType
        preview.seconds = seconds
        preview.waterAmount = selectedType == .wait ? 0 : waterAmount
        preview.orderIndex = Int16(stagesViewModel.formData.stages.count)
        return preview
    }
    
    func previewProgressValue() -> Int16 {
        totalWaterUsed + (selectedType == .wait ? 0 : waterAmount)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Reset water amount when switching to wait type
        $selectedType
            .sink { [weak self] type in
                if type == .wait {
                    self?.waterAmount = 0
                }
            }
            .store(in: &cancellables)
    }
    
    private func initializeSmartDefaults() {
        let currentStages = stagesViewModel.formData.stages
        
        if currentStages.isEmpty {
            // First stage - likely bloom
            selectedType = .fast
            seconds = 15
            waterAmount = min(stagesViewModel.brewMath.grams * 2, availableWater)
        } else if currentStages.count == 1 {
            // Second stage - often a wait after bloom
            selectedType = .wait
            seconds = 30
            waterAmount = 0
        } else {
            // Subsequent stages - usually pours
            selectedType = .slow
            seconds = 30
            
            // Calculate a reasonable water amount
            let remainingStages = max(1, 4 - currentStages.count)
            waterAmount = min(availableWater / Int16(remainingStages), availableWater)
        }
    }
}