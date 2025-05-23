import SwiftUI
import CoreData

struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    @Binding var existingRecipe: Recipe?
    
    @StateObject private var viewModel: AddRecipeViewModel
    
    init(coordinator: AddRecipeCoordinator,
         selectedRoaster: Binding<Roaster?>,
         context: NSManagedObjectContext,
         selectedTab: Binding<MainView.Tab>,
         existingRecipe: Binding<Recipe?>) {
        
        self.coordinator = coordinator
        self._selectedRoaster = selectedRoaster
        self.context = context
        self._selectedTab = selectedTab
        self._existingRecipe = existingRecipe
        
        // Create ViewModel with proper initialization
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster,
            context: context,
            existingRecipe: existingRecipe
        )
        self._viewModel = StateObject(wrappedValue: vm)
        
        print("AddRecipeCoordinatorView init - selectedRoaster: \(selectedRoaster.wrappedValue?.name ?? "nil"), existingRecipe: \(existingRecipe.wrappedValue?.name ?? "nil")")
    }
    
    var body: some View {
        AddRecipe(
            selectedTab: $selectedTab,
            viewModel: viewModel,
        )
        .onAppear {
            print("AddRecipeCoordinatorView appeared - setting viewModel in coordinator")
            coordinator.setViewModel(viewModel)
        }
        .onChange(of: selectedRoaster) { oldValue, newValue in
            print("selectedRoaster changed in coordinator view: \(oldValue?.name ?? "nil") -> \(newValue?.name ?? "nil")")
            // Update viewModel when selectedRoaster changes externally
            if !viewModel.isEditing {
                viewModel.updateSelectedRoaster(newValue)
            }
        }
        .onChange(of: existingRecipe) { oldValue, newValue in
            print("existingRecipe changed: \(oldValue?.name ?? "nil") -> \(newValue?.name ?? "nil")")
        }
    }
}
