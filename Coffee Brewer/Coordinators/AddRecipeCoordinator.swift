import SwiftUI
import CoreData

@MainActor
class AddRecipeCoordinator: ObservableObject {
    @Published var currentViewModel: AddRecipeViewModel?
    private var isRecipeSaved = false
    
    func setViewModel(_ viewModel: AddRecipeViewModel) {
        currentViewModel = viewModel
    }
    
    func resetIfNeeded() {
        guard let viewModel = currentViewModel else { return }
        if !viewModel.isEditing && !isRecipeSaved {
            // Reset form to defaults for new recipes
            viewModel.resetToDefaults()
            currentViewModel = nil
        }
        // Reset the saved flag after use
        isRecipeSaved = false
    }
    
    func hasUnsavedChanges() -> Bool {
        // If recipe was saved, don't consider it as unsaved changes
        if isRecipeSaved {
            return false
        }
        
        guard let viewModel = currentViewModel else { return false }
        return viewModel.hasUnsavedChanges()
    }
    
    func clearViewModel() {
        currentViewModel?.resetToDefaults()
        currentViewModel = nil
        isRecipeSaved = false
    }
    
    func markRecipeAsSaved() {
        isRecipeSaved = true
        // Reset view model state
        currentViewModel?.resetToDefaults()
        currentViewModel = nil
    }
}