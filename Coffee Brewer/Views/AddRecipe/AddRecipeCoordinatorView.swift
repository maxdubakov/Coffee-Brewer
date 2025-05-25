import SwiftUI
import CoreData

struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    @Binding var selectedRecipe: Recipe?
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Root view based on whether we're editing or creating
            if let recipe = selectedRecipe {
                AddRecipeContainer(
                    coordinator: coordinator,
                    selectedRoaster: $selectedRoaster,
                    context: context,
                    selectedTab: $selectedTab,
                    existingRecipe: recipe,
                    navigationPath: $navigationPath
                )
                .id(recipe.objectID)
            } else {
                AddRecipeContainer(
                    coordinator: coordinator,
                    selectedRoaster: $selectedRoaster,
                    context: context,
                    selectedTab: $selectedTab,
                    existingRecipe: nil,
                    navigationPath: $navigationPath
                )
                .id("new-recipe")
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            // Clear navigation when leaving the tab
            if newTab != .add && !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
            }
        }
        .onChange(of: selectedRecipe) { _, _ in
            // Clear navigation when recipe changes
            if !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .recipeSaved)) { _ in
            // Clear navigation after saving
            if !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
            }
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
    @Binding var navigationPath: NavigationPath
    
    @StateObject private var viewModel: AddRecipeViewModel
    
    init(coordinator: AddRecipeCoordinator,
         selectedRoaster: Binding<Roaster?>,
         context: NSManagedObjectContext,
         selectedTab: Binding<MainView.Tab>,
         existingRecipe: Recipe?,
         navigationPath: Binding<NavigationPath>) {
        
        self.coordinator = coordinator
        self._selectedRoaster = selectedRoaster
        self.context = context
        self._selectedTab = selectedTab
        self.existingRecipe = existingRecipe
        self._navigationPath = navigationPath
        
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
            viewModel: viewModel,
            navigationPath: $navigationPath
        )
        .navigationDestination(for: AddRecipeNavigation.self) { destination in
            switch destination {
            case .stages(let formData, let existingRecipeID):
                GlobalBackground {
                    StagesManagementViewWrapper(
                        initialFormData: formData,
                        brewMath: viewModel.brewMath,
                        selectedTab: $selectedTab,
                        context: context,
                        existingRecipeID: existingRecipeID,
                        onFormDataUpdate: { updatedFormData in
                            viewModel.formData = updatedFormData
                        }
                    )
                }
            }
        }
        .onAppear {
            print("AddRecipeContainer appeared - setting viewModel in coordinator")
            coordinator.setViewModel(viewModel)
            // Set navigation callback
            viewModel.onNavigateToStages = { formData, recipeID in
                navigationPath.append(AddRecipeNavigation.stages(formData: formData, existingRecipeID: recipeID))
            }
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