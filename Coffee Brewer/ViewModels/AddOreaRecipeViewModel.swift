import SwiftUI
import CoreData

@MainActor
class AddOreaRecipeViewModel: BaseAddRecipeViewModel {
    
    override var headerTitle: String {
        "New Orea Recipe"
    }
    
    override var headerSubtitle: String {
        "Create a custom Orea V4 recipe with your preferred bottom type."
    }
    
    // Orea-specific initialization
    init(selectedRoaster: Roaster?, selectedGrinder: Grinder? = nil, context: NSManagedObjectContext) {
        super.init(
            selectedRoaster: selectedRoaster,
            selectedGrinder: selectedGrinder,
            brewMethod: .oreaV4,
            context: context
        )
        
        // Orea-specific defaults
        // Orea might have different optimal parameters
        formData.temperature = 93.0  // Slightly lower temp for Orea
        formData.grindSize = 35      // Slightly finer grind
    }
    
    // Orea-specific validation
    override func validateAndContinue() {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Recipe Name")
        }
        
        if formData.roaster == nil {
            missingFields.append("Roaster")
        }
        
        // Orea-specific: ensure bottom type is selected
        if formData.oreaBottomType == nil {
            missingFields.append("Orea Bottom Type")
        }
        
        if missingFields.isEmpty {
            onNavigateToStages?(formData, savedRecipeID)
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
}
