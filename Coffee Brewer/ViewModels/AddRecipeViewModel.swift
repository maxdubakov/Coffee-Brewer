import SwiftUI
import CoreData
import Combine

@MainActor
class AddRecipeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var recipeName: String = "New Recipe"
    @Published var selectedRoaster: Roaster?
    @Published var selectedGrinder: Grinder?
    @Published var temperature: Double = 95.0
    @Published var grindSize: Int16 = 40
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var navigateToStages = false
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private var recipe: Recipe
    private let isEditing: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Observed Objects
    @Published var brewMath: BrewMathViewModel
    
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
    init(selectedRoaster: Binding<Roaster?>, context: NSManagedObjectContext, existingRecipe: Recipe? = nil) {
        self.viewContext = context
        self.isEditing = existingRecipe != nil
        
        if let recipe = existingRecipe {
            self.recipe = recipe
            self.recipeName = recipe.name ?? "New Recipe"
            self.selectedRoaster = recipe.roaster
            self.selectedGrinder = recipe.grinder
            self.temperature = recipe.temperature
            self.grindSize = recipe.grindSize
            
            self.brewMath = BrewMathViewModel(
                grams: recipe.grams,
                ratio: recipe.ratio,
                water: recipe.waterAmount
            )
        } else {
            let draft = Recipe(context: context)
            draft.id = UUID()
            draft.roaster = selectedRoaster.wrappedValue
            draft.name = "New Recipe"
            draft.temperature = 95.0
            draft.grindSize = 40
            
            self.recipe = draft
            self.selectedRoaster = selectedRoaster.wrappedValue
            
            self.brewMath = BrewMathViewModel(
                grams: 18,
                ratio: 16.0,
                water: 288
            )
        }
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Bind recipe name changes
        $recipeName
            .sink { [weak self] newName in
                self?.recipe.name = newName
            }
            .store(in: &cancellables)
        
        // Bind roaster changes
        $selectedRoaster
            .sink { [weak self] roaster in
                self?.recipe.roaster = roaster
            }
            .store(in: &cancellables)
        
        // Bind grinder changes
        $selectedGrinder
            .sink { [weak self] grinder in
                self?.recipe.grinder = grinder
            }
            .store(in: &cancellables)
        
        // Bind temperature changes
        $temperature
            .sink { [weak self] temp in
                self?.recipe.temperature = temp
            }
            .store(in: &cancellables)
        
        // Bind grind size changes
        $grindSize
            .sink { [weak self] size in
                self?.recipe.grindSize = size
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func validateAndContinue() {
        var missingFields: [String] = []
        
        if recipeName.isEmpty {
            missingFields.append("Recipe Name")
        }
        
        if selectedRoaster == nil {
            missingFields.append("Roaster")
        }
        
        if missingFields.isEmpty {
            updateRecipeFromBrewMath()
            saveAndNavigate()
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    private func updateRecipeFromBrewMath() {
        recipe.grams = brewMath.grams
        recipe.ratio = brewMath.ratio
        recipe.waterAmount = brewMath.water
    }
    
    private func saveAndNavigate() {
        isSaving = true
        
        Task {
            do {
                try viewContext.save()
                await MainActor.run {
                    isSaving = false
                    navigateToStages = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    validationMessage = "Error saving recipe: \(error.localizedDescription)"
                    showValidationAlert = true
                }
            }
        }
    }
    
    func getRecipe() -> Recipe {
        return recipe
    }
    
    // MARK: - Entity Validation
    private var isRecipeValid: Bool {
        guard let context = recipe.managedObjectContext else { return false }
        
        // Check if recipe still exists in context
        do {
            let _ = try context.existingObject(with: recipe.objectID)
            return true
        } catch {
            return false
        }
    }
    
    private func ensureValidRecipe() {
        if !isRecipeValid {
            print("Recipe became invalid, creating new one")
            createFreshRecipe()
        }
    }
    
    private func createFreshRecipe() {
        // Create a completely new recipe
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.name = recipeName.isEmpty ? "New Recipe" : recipeName
        newRecipe.temperature = temperature
        newRecipe.grindSize = grindSize
        newRecipe.grams = brewMath.grams
        newRecipe.ratio = brewMath.ratio
        newRecipe.waterAmount = brewMath.water
        
        self.recipe = newRecipe
        if let roaster = selectedRoaster {
            self.selectedRoaster = roaster
        }
        if let grinder = selectedGrinder {
            self.selectedGrinder = grinder
        }
    }
    
    // MARK: - Reset Methods
    func resetToDefaults() {
//        if let currentRecipe = recipe, !isEditing {
//            viewContext.delete(currentRecipe)
//        }
        // Reset UI state first
        recipeName = "New Recipe"
        selectedRoaster = nil
        selectedGrinder = nil
        temperature = 95.0
        grindSize = 40
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        navigateToStages = false
        isSaving = false
        
        // Reset brew math
        brewMath.grams = 18
        brewMath.ratio = 16.0
        brewMath.water = 288
        
        // Create completely fresh recipe (if not editing)
        if !isEditing {
            createFreshRecipe()
        }
        
        print("AddRecipe state reset with fresh recipe")
    }
    
    private func createNewRecipe() {
        // Delete current draft if it exists and wasn't saved
        if !recipe.isInserted || recipe.lastBrewedAt == nil {
            viewContext.delete(recipe)
        }
        
        // Create fresh recipe
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.name = "New Recipe"
        newRecipe.temperature = 95.0
        newRecipe.grindSize = 40
        
        // Update reference (this might need adjustment based on your exact implementation)
        // You may need to make recipe a @Published var instead of let
    }
    
    func viewDidAppear() {
        ensureValidRecipe()
    }
    
    func viewWillDisappear() {
        // Optional: Clean up if needed
        if !isEditing && !isSaving {
            // Don't save draft changes when leaving
            viewContext.rollback()
        }
    }
    
    func shouldResetOnTabChange() -> Bool {
        // Only reset if we're not editing an existing recipe
        return !isEditing
    }
    
    func hasUnsavedChanges() -> Bool {
        // Don't show alert if editing existing recipe
        if isEditing { return false }
        
        // Check if user has made any meaningful changes
        let hasRecipeName = recipeName != "New Recipe" && !recipeName.isEmpty
        let hasRoaster = selectedRoaster != nil
        let hasGrinder = selectedGrinder != nil
        let hasCustomTemp = temperature != 95.0
        let hasCustomGrind = grindSize != 40
        let hasCustomBrewParams = brewMath.grams != 18 || brewMath.ratio != 16.0 || brewMath.water != 288
        
        return hasRecipeName || hasRoaster || hasGrinder ||
               hasCustomTemp || hasCustomGrind || hasCustomBrewParams
    }
}
