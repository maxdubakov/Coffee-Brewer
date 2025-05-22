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
    private var recipe: Recipe?
    private let originalSelectedRoaster: Roaster?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    let isEditing: Bool
    
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
    
    // Safe recipe access - creates if needed
    var currentRecipe: Recipe {
        if let existingRecipe = recipe {
            return existingRecipe
        } else {
            // Create recipe immediately when accessed
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = UUID()
            newRecipe.name = recipeName
            newRecipe.roaster = selectedRoaster
            newRecipe.grinder = selectedGrinder
            newRecipe.temperature = temperature
            newRecipe.grindSize = grindSize
            newRecipe.grams = brewMath.grams
            newRecipe.ratio = brewMath.ratio
            newRecipe.waterAmount = brewMath.water
            
            self.recipe = newRecipe
            setupEditingBindings()
            return newRecipe
        }
    }
    
    // MARK: - Initialization
    init(selectedRoaster: Binding<Roaster?>, context: NSManagedObjectContext, existingRecipe: Recipe? = nil) {
        self.viewContext = context
        self.isEditing = existingRecipe != nil
        self.originalSelectedRoaster = selectedRoaster.wrappedValue
        
        print("AddRecipeViewModel init - isEditing: \(isEditing), selectedRoaster: \(selectedRoaster.wrappedValue?.name ?? "nil"), existingRecipe: \(existingRecipe?.name ?? "nil")")
        
        if let recipe = existingRecipe {
            // EDITING MODE - populate with existing recipe data
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
            
            print("Editing mode initialized with recipe: \(recipe.name ?? "unnamed")")
        } else {
            // NEW RECIPE MODE - use provided roaster or defaults
            self.recipe = nil
            self.selectedRoaster = selectedRoaster.wrappedValue
            
            self.brewMath = BrewMathViewModel(
                grams: 18,
                ratio: 16.0,
                water: 288
            )
            
            print("New recipe mode initialized with selectedRoaster: \(selectedRoaster.wrappedValue?.name ?? "nil")")
        }
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func updateSelectedRoaster(_ roaster: Roaster?) {
        print("updateSelectedRoaster called with: \(roaster?.name ?? "nil")")
        self.selectedRoaster = roaster
    }
    
    // ... rest of the methods remain the same ...
    
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
    
    func validateAndContinue() {
        var missingFields: [String] = []
        
        if recipeName.isEmpty {
            missingFields.append("Recipe Name")
        }
        
        if selectedRoaster == nil {
            missingFields.append("Roaster")
        }
        
        if missingFields.isEmpty {
            // Ensure recipe is created and updated before navigation
            updateRecipeFromCurrentState()
            saveAndNavigate()
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    private func updateRecipeFromCurrentState() {
        // Access currentRecipe to ensure it's created
        let recipe = currentRecipe
        
        // Update with current values
        recipe.name = recipeName
        recipe.roaster = selectedRoaster
        recipe.grinder = selectedGrinder
        recipe.temperature = temperature
        recipe.grindSize = grindSize
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
        return currentRecipe
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
        print("AddRecipeViewModel viewDidAppear - selectedRoaster: \(selectedRoaster?.name ?? "nil")")
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
