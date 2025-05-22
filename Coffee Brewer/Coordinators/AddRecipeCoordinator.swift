import SwiftUI
import CoreData

@MainActor
class AddRecipeCoordinator: ObservableObject {
    @Published var currentViewModel: AddRecipeViewModel?
    
    func setViewModel(_ viewModel: AddRecipeViewModel) {
        currentViewModel = viewModel
    }
    
    func resetIfNeeded() {
        guard let viewModel = currentViewModel else { return }
        if viewModel.shouldResetOnTabChange() {
            viewModel.resetToDefaults()
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        guard let viewModel = currentViewModel else { return false }
        return viewModel.hasUnsavedChanges()
    }
    
    func clearViewModel() {
        currentViewModel = nil
    }
}

// AddRecipeCoordinatorView.swift
struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    let existingRecipe: Recipe?
    
    @StateObject private var viewModel: AddRecipeViewModel
    
    init(coordinator: AddRecipeCoordinator,
         selectedRoaster: Binding<Roaster?>,
         context: NSManagedObjectContext,
         selectedTab: Binding<MainView.Tab>,
         existingRecipe: Recipe?) {
        
        self.coordinator = coordinator
        self._selectedRoaster = selectedRoaster
        self.context = context
        self._selectedTab = selectedTab
        self.existingRecipe = existingRecipe
        
        // Create ViewModel here
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster,
            context: context,
            existingRecipe: existingRecipe
        )
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        AddRecipe(
            selectedTab: $selectedTab,
            viewModel: viewModel,
        )
        .onAppear {
            coordinator.setViewModel(viewModel)
        }
    }
}
