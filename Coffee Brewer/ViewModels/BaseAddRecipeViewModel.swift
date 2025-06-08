import SwiftUI
import CoreData
import Combine

@MainActor
class BaseAddRecipeViewModel: ObservableObject {
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
    @Published var savedRecipeID: NSManagedObjectID?
    
    // MARK: - Computed Properties (Override in subclasses)
    var headerTitle: String {
        "New Recipe"
    }
    
    var headerSubtitle: String {
        "Create a custom coffee recipe with precise brewing parameters."
    }
    
    var continueButtonTitle: String {
        "Continue to Stages"
    }
    
    // MARK: - Initialization
    init(selectedRoaster: Roaster?, selectedGrinder: Grinder? = nil, brewMethod: BrewMethod? = nil, context: NSManagedObjectContext) {
        self.viewContext = context
        let formData = RecipeFormData(selectedRoaster: selectedRoaster, selectedGrinder: selectedGrinder, brewMethod: brewMethod)
        self.formData = formData
        self.brewMath = BrewMathViewModel(
            grams: formData.grams,
            ratio: formData.ratio,
            water: formData.waterAmount
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
            onNavigateToStages?(formData, nil)
        } else {
            validationMessage = "Please, fill in \(missingFields[0])"
            showValidationAlert = true
        }
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

    
    // MARK: - Reset Methods
    func resetToDefaults() {
        formData = RecipeFormData()
        brewMath.grams = 18
        brewMath.ratio = 16.0
        brewMath.water = 288
        
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        isSaving = false
    }
    
    func hasUnsavedChanges() -> Bool {
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
