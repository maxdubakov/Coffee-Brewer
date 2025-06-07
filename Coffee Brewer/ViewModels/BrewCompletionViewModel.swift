import SwiftUI
import CoreData
import Combine

@MainActor
class BrewCompletionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: BrewFormData
    @Published var focusedField: FocusedField?
    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    private let recipe: Recipe
    private let viewContext: NSManagedObjectContext
    var existingBrew: Brew?
    
    // MARK: - Computed Properties
    var roasterName: String {
        recipe.roaster?.name ?? "Unknown Roaster"
    }
    
    var recipeName: String {
        recipe.name ?? "Untitled Recipe"
    }
    
    // MARK: - Initialization
    init(brew: Brew, context: NSManagedObjectContext) {
        self.existingBrew = brew
        self.recipe = brew.recipe ?? Recipe(context: context)
        self.viewContext = context
        self.formData = BrewFormData(from: brew)
    }
    
    init(recipe: Recipe, actualElapsedTime: Double, context: NSManagedObjectContext) {
        self.recipe = recipe
        self.viewContext = context
        self.formData = BrewFormData(recipe: recipe, actualElapsedTime: actualElapsedTime)
    }
    
    // MARK: - Public Methods
    func saveBrewExperience() async {
        isSaving = true
        
        do {
            let brew: Brew
            
            if let existingBrew = existingBrew {
                // Update existing brew
                brew = existingBrew
            } else {
                // Create new brew
                brew = Brew(context: viewContext)
                brew.id = UUID()
                brew.date = formData.date
                brew.actualDurationSeconds = formData.actualDurationSeconds
                brew.recipe = recipe
                
                // Copy recipe data for historical preservation
                brew.recipeName = formData.recipeName
                brew.recipeGrams = formData.recipeGrams
                brew.recipeWaterAmount = formData.recipeWaterAmount
                brew.recipeRatio = formData.recipeRatio
                brew.recipeTemperature = formData.recipeTemperature
                brew.recipeGrindSize = formData.recipeGrindSize
                brew.roasterName = formData.roasterName
                brew.grinderName = formData.grinderName
            }
            
            // Update assessment data
            brew.name = formData.name.isEmpty ? nil : formData.name
            brew.rating = formData.rating
            brew.acidity = formData.acidity
            brew.bitterness = formData.bitterness
            brew.body = formData.body
            brew.sweetness = formData.sweetness
            brew.tds = formData.tds
            brew.notes = formData.notes.isEmpty ? nil : formData.notes
            brew.isAssessed = true
            
            // Update recipe's last brewed date if creating new brew
            if existingBrew == nil {
                recipe.lastBrewedAt = Date()
            }
            
            try viewContext.save()
            
        } catch {
            errorMessage = "Failed to save brew experience: \(error.localizedDescription)"
            showError = true
        }
        
        isSaving = false
    }
    
    func updateRating(_ rating: Int16) {
        formData.rating = rating
    }
    
    func updateBitterness(_ bitterness: Int16) {
        formData.bitterness = bitterness
    }
    
    func updateAcidity(_ acidity: Int16) {
        formData.acidity = acidity
    }
    
    func updateSweetness(_ sweetness: Int16) {
        formData.sweetness = sweetness
    }
    
    func updateBody(_ body: Int16) {
        formData.body = body
    }
    
    func updateNotes(_ notes: String) {
        formData.notes = notes
    }
}