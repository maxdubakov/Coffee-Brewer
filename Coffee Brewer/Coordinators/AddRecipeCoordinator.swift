import SwiftUI
import CoreData

@MainActor
class AddRecipeCoordinator: ObservableObject {
    weak var addRecipeViewModel: AddRecipeViewModel?
    private var isRecipeSaved = false
    
    func setViewModel(_ viewModel: AddRecipeViewModel) {
        self.addRecipeViewModel = viewModel
    }
    
    func resetIfNeeded() {
        if !isRecipeSaved {
            addRecipeViewModel?.resetToDefaults()
        }
        isRecipeSaved = false
    }
    
    func hasUnsavedChanges() -> Bool {
        if isRecipeSaved {
            return false
        }
        return addRecipeViewModel?.hasUnsavedChanges() ?? false
    }
    
    func markRecipeAsSaved() {
        isRecipeSaved = true
        addRecipeViewModel?.resetToDefaults()
    }
}