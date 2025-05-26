import Foundation
import CoreData

enum AddRecipeNavigation: Hashable {
    case stageChoice(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    case stages(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    case recordStages(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    
    // Custom hash and equality to avoid issues with RecipeFormData
    func hash(into hasher: inout Hasher) {
        switch self {
        case .stageChoice(_, let existingRecipeID):
            hasher.combine("stageChoice")
            hasher.combine(existingRecipeID)
        case .stages(_, let existingRecipeID):
            hasher.combine("stages")
            hasher.combine(existingRecipeID)
        case .recordStages(_, let existingRecipeID):
            hasher.combine("recordStages")
            hasher.combine(existingRecipeID)
        }
    }
    
    static func == (lhs: AddRecipeNavigation, rhs: AddRecipeNavigation) -> Bool {
        switch (lhs, rhs) {
        case (.stageChoice(let lhsData, let lhsID), .stageChoice(let rhsData, let rhsID)):
            return lhsData == rhsData && lhsID == rhsID
        case (.stages(let lhsData, let lhsID), .stages(let rhsData, let rhsID)):
            return lhsData == rhsData && lhsID == rhsID
        case (.recordStages(let lhsData, let lhsID), .recordStages(let rhsData, let rhsID)):
            return lhsData == rhsData && lhsID == rhsID
        default:
            return false
        }
    }
}