import SwiftUI
import CoreData

struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    @Binding var selectedRecipe: Recipe?
    
    var body: some View {
        // Use the recipe's objectID as the view's identity
        // This forces the view to recreate when switching between recipes
        if let recipe = selectedRecipe {
            AddRecipeContainer(
                coordinator: coordinator,
                selectedRoaster: $selectedRoaster,
                context: context,
                selectedTab: $selectedTab,
                existingRecipe: recipe
            )
            .id(recipe.objectID)
        } else {
            AddRecipeContainer(
                coordinator: coordinator,
                selectedRoaster: $selectedRoaster,
                context: context,
                selectedTab: $selectedTab,
                existingRecipe: nil
            )
            .id("new-recipe")
        }
    }
}

// Separate container to ensure proper ViewModel initialization
struct AddRecipeContainer: View {
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
        
        // Create ViewModel with proper initialization
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster.wrappedValue,
            context: context,
            existingRecipe: existingRecipe
        )
        self._viewModel = StateObject(wrappedValue: vm)
        
        print("AddRecipeContainer init - selectedRoaster: \(selectedRoaster.wrappedValue?.name ?? "nil"), existingRecipe: \(existingRecipe?.name ?? "nil")")
    }
    
    var body: some View {
        AddRecipe(
            selectedTab: $selectedTab,
            viewModel: viewModel
        )
        .onAppear {
            print("AddRecipeContainer appeared - setting viewModel in coordinator")
            coordinator.setViewModel(viewModel)
        }
        .onChange(of: selectedRoaster) { oldValue, newValue in
            print("selectedRoaster changed in container view: \(oldValue?.name ?? "nil") -> \(newValue?.name ?? "nil")")
            // Update viewModel when selectedRoaster changes externally
            if !viewModel.isEditing {
                viewModel.updateSelectedRoaster(newValue)
            }
        }
    }
}