import SwiftUI
import CoreData
import Combine

@MainActor
class StagesManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var focusedField: FocusedField?
    @Published var editMode: EditMode = .inactive
    @Published var isAddingStage = false
    @Published var stageBeingModified: Stage?
    @Published var showingSaveAlert = false
    @Published var alertMessage = ""
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private let recipe: Recipe
    private let brewMath: BrewMathViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var headerTitle: String {
        "Recipe Stages"
    }
    
    var headerSubtitle: String {
        recipe.stagesArray.isEmpty ? "Add brewing stages to your recipe" : ""
    }
    
    var hasStages: Bool {
        !recipe.stagesArray.isEmpty
    }
    
    var editButtonTitle: String {
        editMode == .active ? "Done" : "Edit"
    }
    
    var currentWater: Int16 {
        recipe.totalStageWater
    }
    
    var totalWater: Int16 {
        brewMath.water
    }
    
    var stages: [Stage] {
        recipe.stagesArray
    }
    
    var recipeForStageManagement: Recipe {
        recipe
    }
    
    var brewMathForStageManagement: BrewMathViewModel {
        brewMath
    }
    
    var contextForStageManagement: NSManagedObjectContext {
        viewContext
    }

    // MARK: - Initialization
    init(recipe: Recipe, brewMath: BrewMathViewModel, context: NSManagedObjectContext) {
        self.recipe = recipe
        self.brewMath = brewMath
        self.viewContext = context
        
        setupInitialStage()
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
    
    func editStage(_ stage: Stage) {
        if editMode == .inactive {
            stageBeingModified = stage
        }
    }
    
    func moveStages(from source: IndexSet, to destination: Int) {
        var stages = recipe.stagesArray
        stages.move(fromOffsets: source, toOffset: destination)
        
        // Update order indices
        for (index, stage) in stages.enumerated() {
            stage.orderIndex = Int16(index)
        }
        
        saveContext()
    }
    
    func deleteStages(at offsets: IndexSet) {
        let stagesToDelete = offsets.map { recipe.stagesArray[$0] }

        for stage in stagesToDelete {
            viewContext.delete(stage)
        }
        
        saveContext()

        // Reindex remaining stages
        let remainingStages = recipe.stagesArray
        for (index, remainingStage) in remainingStages.enumerated() {
            remainingStage.orderIndex = Int16(index)
        }
    }
    
    func moveStageUp(_ stage: Stage) {
        guard stage.orderIndex > 0 else { return }
        
        let currentIndex = Int(stage.orderIndex)
        let newIndex = currentIndex - 1
        
        if let stageAbove = recipe.stagesArray.first(where: { $0.orderIndex == Int16(newIndex) }) {
            stageAbove.orderIndex = Int16(currentIndex)
            stage.orderIndex = Int16(newIndex)
            saveContext()
        }
    }
    
    func moveStageDown(_ stage: Stage) {
        let currentIndex = Int(stage.orderIndex)
        let newIndex = currentIndex + 1
        
        if let stageBelow = recipe.stagesArray.first(where: { $0.orderIndex == Int16(newIndex) }) {
            stageBelow.orderIndex = Int16(currentIndex)
            stage.orderIndex = Int16(newIndex)
            saveContext()
        }
    }
    
    func saveRecipe(completion: @escaping (Bool) -> Void) {
        // Validate stages before saving
        if recipe.stagesArray.isEmpty {
            alertMessage = "Please add at least one brewing stage"
            showingSaveAlert = true
            completion(false)
            return
        }
        
        if !recipe.isStageWaterBalanced {
            alertMessage = "Stage water total (\(recipe.totalStageWater)ml) doesn't match recipe water amount (\(brewMath.water)ml). Would you like to adjust the recipe water amount?"
            showingSaveAlert = true
            completion(false)
            return
        }
        
        isSaving = true
        
        Task {
            await MainActor.run {
                do {
                    // If this is a new recipe, set the last brewed date
                    if recipe.lastBrewedAt == nil {
                        recipe.lastBrewedAt = Date()
                    }
                    
                    // Update recipe with brew math values
                    recipe.grams = brewMath.grams
                    recipe.ratio = brewMath.ratio
                    recipe.waterAmount = brewMath.water
                    
                    try viewContext.save()
                    isSaving = false
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
    
    func progressValue(for stage: Stage) -> Int16 {
        recipe.totalStageWaterToStep(stepIndex: Int(stage.orderIndex))
    }
    
    // MARK: - Private Methods
    private func setupInitialStage() {
        if recipe.stagesArray.isEmpty {
            recipe.createDefaultStage(context: viewContext)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
