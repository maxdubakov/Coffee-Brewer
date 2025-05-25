import Foundation
import CoreData

enum AddRecipeNavigation: Hashable {
    case stages(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    
    // Custom hash and equality to avoid issues with RecipeFormData
    func hash(into hasher: inout Hasher) {
        switch self {
        case .stages(_, let existingRecipeID):
            hasher.combine("stages")
            hasher.combine(existingRecipeID)
        }
    }
    
    static func == (lhs: AddRecipeNavigation, rhs: AddRecipeNavigation) -> Bool {
        switch (lhs, rhs) {
        case (.stages(let lhsData, let lhsID), .stages(let rhsData, let rhsID)):
            return lhsData == rhsData && lhsID == rhsID
        }
    }
}