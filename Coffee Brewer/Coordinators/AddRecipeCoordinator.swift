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
        if !isRecipeSaved {
            viewModel.resetToDefaults()
            currentViewModel = nil
        }
        isRecipeSaved = false
    }
    
    func hasUnsavedChanges() -> Bool {
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
        currentViewModel?.resetToDefaults()
        currentViewModel = nil
    }
}
