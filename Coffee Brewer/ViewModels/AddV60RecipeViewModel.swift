import SwiftUI
import CoreData

@MainActor
class AddV60RecipeViewModel: BaseAddRecipeViewModel {
    
    override var headerTitle: String {
        "New V60 Recipe"
    }
    
    override var headerSubtitle: String {
        "Create a custom V60 pour-over recipe with precise parameters."
    }
    
    // V60-specific initialization
    init(selectedRoaster: Roaster?, selectedGrinder: Grinder? = nil, context: NSManagedObjectContext) {
        super.init(
            selectedRoaster: selectedRoaster,
            selectedGrinder: selectedGrinder,
            brewMethod: .v60,
            context: context
        )
        
        // V60-specific defaults (if needed)
        // For example, V60 might have different default temperatures or ratios
    }
    
    // V60-specific validation or business logic can be added here
    override func validateAndContinue() {
        // Can add V60-specific validation if needed
        super.validateAndContinue()
    }
}