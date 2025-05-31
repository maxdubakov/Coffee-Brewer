import SwiftUI
import CoreData
import Combine

@MainActor
class StagesManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: RecipeFormData
    @Published var brewMath: BrewMathViewModel
    @Published var focusedField: FocusedField?
    @Published var editMode: EditMode = .inactive
    @Published var isAddingStage = false
    @Published var stageBeingModified: StageFormData?
    @Published var showingSaveAlert = false
    @Published var alertMessage = ""
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private let existingRecipeID: NSManagedObjectID?
    private var cancellables = Set<AnyCancellable>()
    
    
    var hasStages: Bool {
        !formData.stages.isEmpty
    }
    
    var editButtonTitle: String {
        editMode == .active ? "Done" : "Edit"
    }
    
    var currentWater: Int16 {
        formData.totalStageWater
    }
    
    var totalWater: Int16 {
        brewMath.water
    }
    
    var stages: [StageFormData] {
        formData.stages
    }
    
    func progressValue(for stage: StageFormData) -> Int16 {
        guard let index = formData.stages.firstIndex(where: { $0.id == stage.id }) else { return 0 }
        return formData.stages[0..<index].reduce(0) { $0 + $1.waterAmount } + stage.waterAmount
    }

    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel, context: NSManagedObjectContext, existingRecipeID: NSManagedObjectID?) {
        self.formData = formData
        self.brewMath = brewMath
        self.viewContext = context
        self.existingRecipeID = existingRecipeID
        
        setupInitialStage()
        setupBindings()
    }
    
    // MARK: - Public Methods
    func toggleEditMode() {
        withAnimation {
            editMode = editMode == .active ? .inactive : .active
        }
    }
    
    func addStage() {
        isAddingStage = true
    }
    
    func editStage(_ stage: StageFormData) {
        if editMode == .inactive {
            stageBeingModified = stage
        }
    }
    
    func moveStages(from source: IndexSet, to destination: Int) {
        formData.stages.move(fromOffsets: source, toOffset: destination)
        
        // Update order indices
        for (index, _) in formData.stages.enumerated() {
            formData.stages[index].orderIndex = Int16(index)
        }
    }
    
    func deleteStages(at offsets: IndexSet) {
        formData.stages.remove(atOffsets: offsets)
        
        // Reindex remaining stages
        for (index, _) in formData.stages.enumerated() {
            formData.stages[index].orderIndex = Int16(index)
        }
    }
    
    func moveStageUp(_ stage: StageFormData) {
        guard let currentIndex = formData.stages.firstIndex(where: { $0.id == stage.id }),
              currentIndex > 0 else { return }
        
        formData.stages.swapAt(currentIndex, currentIndex - 1)
        updateOrderIndices()
    }
    
    func moveStageDown(_ stage: StageFormData) {
        guard let currentIndex = formData.stages.firstIndex(where: { $0.id == stage.id }),
              currentIndex < formData.stages.count - 1 else { return }
        
        formData.stages.swapAt(currentIndex, currentIndex + 1)
        updateOrderIndices()
    }
    
    func saveRecipe(completion: @escaping (Bool) -> Void) {
        // Validate stages before saving
        if formData.stages.isEmpty {
            alertMessage = "Please add at least one brewing stage"
            showingSaveAlert = true
            completion(false)
            return
        }
        
        if !formData.isStageWaterBalanced {
            alertMessage = "Sum of the water in stages does not match total water"
            showingSaveAlert = true
            completion(false)
            return
        }
        
        isSaving = true

        Task {
            await MainActor.run {
                do {
                    // Create or update the recipe
                    let recipe: Recipe
                    
                    if let existingID = existingRecipeID,
                       let existing = try? viewContext.existingObject(with: existingID) as? Recipe {
                        recipe = existing
                    } else {
                        recipe = Recipe(context: viewContext)
                        recipe.id = UUID()
                        recipe.lastBrewedAt = Date()
                    }
                    
                    // Update recipe with form data
                    recipe.name = formData.name
                    recipe.roaster = formData.roaster
                    recipe.grinder = formData.grinder
                    recipe.temperature = formData.temperature
                    recipe.grindSize = formData.grindSize
                    recipe.grams = brewMath.grams
                    recipe.ratio = brewMath.ratio
                    recipe.waterAmount = brewMath.water
                    
                    // Delete existing stages if updating
                    if existingRecipeID != nil {
                        recipe.stagesArray.forEach { viewContext.delete($0) }
                    }
                    
                    // Create stages from form data
                    for (index, stageData) in formData.stages.enumerated() {
                        let stage = Stage(context: viewContext)
                        stage.id = UUID()
                        stage.type = stageData.type.id
                        stage.seconds = stageData.seconds
                        stage.waterAmount = stageData.waterAmount
                        stage.orderIndex = Int16(index)
                        stage.recipe = recipe
                    }
                    
                    try viewContext.save()
                    isSaving = false
                    
                    // Mark the recipe as successfully saved
                    NotificationCenter.default.post(
                        name: .recipeSaved,
                        object: nil,
                        userInfo: ["recipe": recipe]
                    )
                    
                    completion(true)
                } catch {
                    isSaving = false
                    alertMessage = "Error saving recipe: \(error.localizedDescription)"
                    showingSaveAlert = true
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Stage Management
    func addStage(_ stage: StageFormData) {
        var newStage = stage
        newStage.orderIndex = Int16(formData.stages.count)
        formData.stages.append(newStage)
    }
    
    func updateStage(_ updatedStage: StageFormData) {
        if let index = formData.stages.firstIndex(where: { $0.id == updatedStage.id }) {
            formData.stages[index] = updatedStage
        }
    }
    
    // MARK: - Private Methods
    private func setupInitialStage() {
        // If no stages exist and it's a new recipe, create a default bloom stage
        if formData.stages.isEmpty && existingRecipeID == nil {
            var bloomStage = StageFormData()
            bloomStage.type = .fast
            bloomStage.seconds = 15
            bloomStage.waterAmount = min(brewMath.grams * 2, brewMath.water)
            bloomStage.orderIndex = 0
            formData.stages.append(bloomStage)
        }
    }
    
    private func setupBindings() {
        // Sync brew math changes
        brewMath.$water
            .sink { [weak self] water in
                self?.formData.waterAmount = water
            }
            .store(in: &cancellables)
        
        brewMath.$grams
            .sink { [weak self] grams in
                self?.formData.grams = grams
            }
            .store(in: &cancellables)
        
        brewMath.$ratio
            .sink { [weak self] ratio in
                self?.formData.ratio = ratio
            }
            .store(in: &cancellables)
    }
    
    private func updateOrderIndices() {
        for (index, _) in formData.stages.enumerated() {
            formData.stages[index].orderIndex = Int16(index)
        }
    }
}
