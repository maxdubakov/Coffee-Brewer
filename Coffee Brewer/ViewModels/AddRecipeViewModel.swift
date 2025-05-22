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
    private var recipe: Recipe?  // Made optional to prevent premature creation
    private let isEditing: Bool
    private var cancellables = Set<AnyCancellable>()
    private let originalSelectedRoaster: Roaster?  // Store original for reset
    
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
        self.originalSelectedRoaster = selectedRoaster.wrappedValue
        
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
            // Don't create recipe immediately for new recipes
            self.recipe = nil
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
        // Only bind to recipe properties if recipe exists (editing mode)
        if isEditing {
            setupEditingBindings()
        }
    }
    
    private func setupEditingBindings() {
        guard let recipe = recipe else { return }
        
        // Bind recipe name changes
        $recipeName
            .sink { [weak self] newName in
                self?.recipe?.name = newName
            }
            .store(in: &cancellables)
        
        // Bind roaster changes
        $selectedRoaster
            .sink { [weak self] roaster in
                self?.recipe?.roaster = roaster
            }
            .store(in: &cancellables)
        
        // Bind grinder changes
        $selectedGrinder
            .sink { [weak self] grinder in
                self?.recipe?.grinder = grinder
            }
            .store(in: &cancellables)
        
        // Bind temperature changes
        $temperature
            .sink { [weak self] temp in
                self?.recipe?.temperature = temp
            }
            .store(in: &cancellables)
        
        // Bind grind size changes
        $grindSize
            .sink { [weak self] size in
                self?.recipe?.grindSize = size
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
            createOrUpdateRecipe()
            saveAndNavigate()
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    private func createOrUpdateRecipe() {
        if recipe == nil {
            // Create recipe only when needed (during validation)
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = UUID()
            self.recipe = newRecipe
            setupEditingBindings()  // Setup bindings after creation
        }
        
        // Update recipe with current values
        recipe?.name = recipeName
        recipe?.roaster = selectedRoaster
        recipe?.grinder = selectedGrinder
        recipe?.temperature = temperature
        recipe?.grindSize = grindSize
        recipe?.grams = brewMath.grams
        recipe?.ratio = brewMath.ratio
        recipe?.waterAmount = brewMath.water
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
        guard let recipe = recipe else {
            fatalError("Recipe should be created before accessing it")
        }
        return recipe
    }
    
    // MARK: - Reset Methods
    func resetToDefaults(deleteRecipe: Bool = true) {
        // Only delete recipe if we're discarding (not if successfully saved)
        if let currentRecipe = recipe, !isEditing && deleteRecipe {
            viewContext.delete(currentRecipe)
            // Force immediate processing of deletion
            try? viewContext.save()
        }
        
        // Reset all state to initial values
        recipeName = "New Recipe"
        selectedRoaster = originalSelectedRoaster
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
        
        // Clear recipe reference
        recipe = nil
        
        // Clear bindings
        cancellables.removeAll()
        
        let action = deleteRecipe ? "reset with recipe deletion" : "reset after successful save"
        print("AddRecipe state \(action)")
    }

    func resetAfterSuccessfulSave() {
        resetToDefaults(deleteRecipe: false)
    }

    func resetAndDiscardChanges() {
        resetToDefaults(deleteRecipe: true)
    }
    
    func viewDidAppear() {
        // Only ensure valid recipe if editing
        if isEditing {
            ensureValidRecipe()
        }
    }
    
    func viewWillDisappear() {
        // Clean up if not saving and not editing
        if !isEditing && !isSaving {
            if let draftRecipe = recipe {
                viewContext.delete(draftRecipe)
            }
            viewContext.rollback()
        }
    }
    
    private func ensureValidRecipe() {
        guard let recipe = recipe else { return }
        guard let context = recipe.managedObjectContext else { return }
        
        // Check if recipe still exists in context
        do {
            let _ = try context.existingObject(with: recipe.objectID)
        } catch {
            print("Recipe became invalid, resetting")
            self.recipe = nil
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
        let hasRoaster = selectedRoaster != originalSelectedRoaster
        let hasGrinder = selectedGrinder != nil
        let hasCustomTemp = temperature != 95.0
        let hasCustomGrind = grindSize != 40
        let hasCustomBrewParams = brewMath.grams != 18 || brewMath.ratio != 16.0 || brewMath.water != 288
        
        return hasRecipeName || hasRoaster || hasGrinder ||
               hasCustomTemp || hasCustomGrind || hasCustomBrewParams
    }
}

extension Notification.Name {
    static let recipeSaved = Notification.Name("recipeSaved")
}
