import SwiftUI
import CoreData
import Combine

@MainActor
class EditRecipeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: RecipeFormData
    @Published var brewMath: BrewMathViewModel
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false
    
    // MARK: - Navigation
    var onNavigateToStages: ((RecipeFormData, NSManagedObjectID?) -> Void)?
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private let originalFormData: RecipeFormData
    private let recipe: Recipe
    
    // MARK: - Computed Properties
    var headerTitle: String {
        "Edit Recipe"
    }
    
    var headerSubtitle: String {
        "Modify your coffee recipe details."
    }
    
    var continueButtonTitle: String {
        "Continue to Stages"
    }
    
    // MARK: - Initialization
    init(recipe: Recipe, context: NSManagedObjectContext) {
        self.viewContext = context
        self.recipe = recipe
        
        // Initialize form data from existing recipe
        let recipeData = RecipeFormData(from: recipe)
        self.originalFormData = recipeData
        self.formData = recipeData
        self.brewMath = BrewMathViewModel(
            grams: recipe.grams,
            ratio: recipe.ratio,
            water: recipe.waterAmount
        )
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func updateSelectedRoaster(_ roaster: Roaster?) {
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
            onNavigateToStages?(formData, recipe.objectID)
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        return formData != originalFormData
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
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
}