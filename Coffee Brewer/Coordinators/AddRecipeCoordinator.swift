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
        if viewModel.shouldResetOnTabChange() && !isRecipeSaved {
            // Reset and discard changes (delete recipe)
            viewModel.resetAndDiscardChanges()
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
        currentViewModel?.resetAndDiscardChanges()
        currentViewModel = nil
        isRecipeSaved = false
    }
    
    func markRecipeAsSaved() {
        isRecipeSaved = true
        // Reset view model state but DON'T delete the saved recipe
        currentViewModel?.resetAfterSuccessfulSave()
        currentViewModel = nil
    }
}


