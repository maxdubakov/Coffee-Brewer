import SwiftUI
import CoreData

@MainActor
class AddRecipeCoordinator: ObservableObject {
    private var addRecipeView: AddRecipeView?
    private var isRecipeSaved = false
    
    func setAddRecipeView(_ view: AddRecipeView) {
        addRecipeView = view
    }
    
    func resetIfNeeded() {
        if !isRecipeSaved {
            addRecipeView?.resetIfNeeded()
        }
        isRecipeSaved = false
    }
    
    func hasUnsavedChanges() -> Bool {
        if isRecipeSaved {
            return false
        }
        return addRecipeView?.hasUnsavedChanges() ?? false
    }
    
    func markRecipeAsSaved() {
        isRecipeSaved = true
        addRecipeView?.resetIfNeeded()
    }
}