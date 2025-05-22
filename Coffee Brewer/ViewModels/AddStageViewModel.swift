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
    private let viewContext: NSManagedObjectContext
    private let recipe: Recipe
    private let brewMath: BrewMathViewModel
    private let existingStage: Stage?
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
        var amount = recipe.stagesArray.reduce(0) { $0 + $1.waterAmount }
        if isEditMode {
            amount -= existingStage?.waterAmount ?? 0
        }
        return amount
    }
    
    var remainingWater: Int16 {
        brewMath.water - totalWaterUsed
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
        recipe.waterAmount
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
        if selectedType != .wait {
            return "How long this pour should take"
        } else {
            return "How long to wait before the next stage"
        }
    }
    
    var showWaterSection: Bool {
        selectedType != .wait
    }
    
    var availableWaterText: String {
        "Available: \(availableWater) ml"
    }
    
    var availableWaterColor: Color {
        waterAmount > availableWater ? Color.red : BrewerColors.textSecondary
    }
    
    var useAllButtonEnabled: Bool {
        availableWater > 0
    }
    
    // MARK: - Initialization
    init(recipe: Recipe, brewMath: BrewMathViewModel, context: NSManagedObjectContext, existingStage: Stage? = nil) {
        self.recipe = recipe
        self.brewMath = brewMath
        self.viewContext = context
        self.existingStage = existingStage
        
        if let stage = existingStage {
            self.selectedType = StageType.fromString(stage.type ?? "fast") ?? .fast
            self.seconds = stage.seconds
            self.waterAmount = stage.waterAmount
        }
        
        setupBindings()
        updateDefaultValues()
    }
    
    // MARK: - Public Methods
    func useAllWater() {
        waterAmount = availableWater
    }
    
    func saveOrUpdateStage(completion: @escaping (Bool) -> Void) {
        // Validate before saving
        if selectedType != .wait && (waterAmount <= 0 || waterAmount > availableWater) {
            errorMessage = "Water amount must be between 1 and \(availableWater) ml"
            showSaveError = true
            completion(false)
            return
        }
        
        if seconds <= 0 {
            errorMessage = "Duration must be greater than 0 seconds"
            showSaveError = true
            completion(false)
            return
        }
        
        if let stageToUpdate = existingStage {
            // Update existing stage
            stageToUpdate.type = selectedType.id
            stageToUpdate.seconds = seconds
            stageToUpdate.waterAmount = selectedType == .wait ? 0 : waterAmount
        } else {
            // Create new stage
            let newStage = Stage(context: viewContext)
            newStage.id = UUID()
            newStage.type = selectedType.id
            newStage.orderIndex = Int16(recipe.stagesArray.count)
            newStage.seconds = seconds
            newStage.waterAmount = selectedType == .wait ? 0 : waterAmount
            recipe.addToStages(newStage)
        }
        
        do {
            try viewContext.save()
            
            // Provide haptic feedback for success
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            completion(true)
        } catch {
            errorMessage = "Failed to save stage: \(error.localizedDescription)"
            showSaveError = true
            completion(false)
        }
    }
    
    func createPreviewStage() -> Stage {
        let previewStage = Stage(context: viewContext)
        previewStage.id = UUID()
        previewStage.type = selectedType.id
        previewStage.waterAmount = selectedType == .wait ? 0 : waterAmount
        previewStage.seconds = seconds
        previewStage.orderIndex = existingStage?.orderIndex ?? Int16(recipe.stagesArray.count)
        return previewStage
    }
    
    func previewProgressValue() -> Int16 {
        recipe.totalStageWater + (selectedType == .wait ? 0 : waterAmount)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $selectedType
            .sink { [weak self] _ in
                self?.updateDefaultValues()
            }
            .store(in: &cancellables)
    }
    
    private func updateDefaultValues() {
        // Don't override values when in edit mode
        if existingStage != nil {
            return
        }
        
        switch selectedType.id {
        case "fast", "slow":
            if availableWater < waterAmount {
                waterAmount = availableWater > 0 ? availableWater : 0
            }
        case "wait":
            seconds = 30
        default:
            break
        }
    }
}
