import SwiftUI
import CoreData
import Combine

@MainActor
class AddRecipeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: RecipeFormData
    @Published var brewMath: BrewMathViewModel
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    // Navigation
    var onNavigateToStages: ((RecipeFormData, NSManagedObjectID?) -> Void)?
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Recipe tracking
    let existingRecipeID: NSManagedObjectID?
    @Published var savedRecipeID: NSManagedObjectID?
    
    // MARK: - Public Properties
    let isEditing: Bool
    
    // MARK: - Computed Properties
    var headerTitle: String {
        isEditing ? "Edit Recipe" : "New Recipe"
    }
    
    var headerSubtitle: String {
        "Create a custom coffee recipe with precise brewing parameters."
    }
    
    var continueButtonTitle: String {
        "Continue to Stages"
    }
    
    // MARK: - Initialization
    init(selectedRoaster: Roaster?, context: NSManagedObjectContext, existingRecipe: Recipe? = nil) {
        self.viewContext = context
        self.existingRecipeID = existingRecipe?.objectID
        self.isEditing = existingRecipe != nil
        
        print("AddRecipeViewModel init - isEditing: \(isEditing), selectedRoaster: \(selectedRoaster?.name ?? "nil"), existingRecipe: \(existingRecipe?.name ?? "nil")")
        
        if let recipe = existingRecipe {
            // EDITING MODE - populate from existing recipe
            self.formData = RecipeFormData(from: recipe)
            self.brewMath = BrewMathViewModel(
                grams: recipe.grams,
                ratio: recipe.ratio,
                water: recipe.waterAmount
            )
            print("Editing mode initialized with recipe: \(recipe.name ?? "unnamed")")
            print("Form data populated - name: \(formData.name), roaster: \(formData.roaster?.name ?? "nil"), temp: \(formData.temperature)")
        } else {
            // NEW RECIPE MODE - use selected roaster
            self.formData = RecipeFormData(selectedRoaster: selectedRoaster)
            self.brewMath = BrewMathViewModel(
                grams: 18,
                ratio: 16.0,
                water: 288
            )
            print("New recipe mode initialized with selectedRoaster: \(selectedRoaster?.name ?? "nil")")
        }
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func updateSelectedRoaster(_ roaster: Roaster?) {
        print("updateSelectedRoaster called with: \(roaster?.name ?? "nil")")
        self.formData.roaster = roaster
    }
    
    func validateAndContinue() {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Recipe Name")
        }
        
        if formData.roaster == nil {
            missingFields.append("Roaster")
        }
        
        if missingFields.isEmpty {
            // Navigate to stages with current form data
            onNavigateToStages?(formData, existingRecipeID)
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }

    
    // MARK: - Private Methods
    private func setupBindings() {
        // Sync brew math changes back to form data
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
        
        brewMath.$water
            .sink { [weak self] water in
                self?.formData.waterAmount = water
            }
            .store(in: &cancellables)
    }

    
    // MARK: - Reset Methods
    func resetToDefaults() {
        // Reset all state to initial values
        formData = RecipeFormData()
        brewMath.grams = 18
        brewMath.ratio = 16.0
        brewMath.water = 288
        
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        isSaving = false
        
        print("AddRecipe state reset to defaults")
    }
    
    func hasUnsavedChanges() -> Bool {
        // Don't show alert if editing existing recipe
        if isEditing { return false }
        
        // Check if user has made any meaningful changes
        let hasRecipeName = formData.name != "New Recipe" && !formData.name.isEmpty
        let hasRoaster = formData.roaster != nil
        let hasGrinder = formData.grinder != nil
        let hasCustomTemp = formData.temperature != 95.0
        let hasCustomGrind = formData.grindSize != 40
        let hasCustomBrewParams = brewMath.grams != 18 || brewMath.ratio != 16.0 || brewMath.water != 288
        
        return hasRecipeName || hasRoaster || hasGrinder ||
               hasCustomTemp || hasCustomGrind || hasCustomBrewParams
    }
}

extension Notification.Name {
    static let recipeSaved = Notification.Name("recipeSaved")
}