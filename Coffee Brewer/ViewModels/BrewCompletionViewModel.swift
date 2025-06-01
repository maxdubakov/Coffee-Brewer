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
    
    // MARK: - Computed Properties
    var roasterName: String {
        recipe.roaster?.name ?? "Unknown Roaster"
    }
    
    var recipeName: String {
        recipe.name ?? "Untitled Recipe"
    }
    
    // MARK: - Initialization
    init(recipe: Recipe, actualElapsedTime: Double, context: NSManagedObjectContext) {
        self.recipe = recipe
        self.viewContext = context
        self.formData = BrewFormData(recipe: recipe, actualElapsedTime: actualElapsedTime)
    }
    
    // MARK: - Public Methods
    func saveBrewExperience() async {
        isSaving = true
        
        do {
            let brew = Brew(context: viewContext)
            brew.id = UUID()
            brew.name = formData.name
            brew.rating = formData.rating
            brew.acidity = formData.acidity
            brew.bitterness = formData.bitterness
            brew.body = formData.body
            brew.sweetness = formData.sweetness
            brew.tds = formData.tds
            brew.notes = formData.notes.isEmpty ? nil : formData.notes
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
            
            // Update recipe's last brewed date
            recipe.lastBrewedAt = Date()
            
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