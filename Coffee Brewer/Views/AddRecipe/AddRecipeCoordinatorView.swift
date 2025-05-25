import SwiftUI
import CoreData

struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AddRecipeContainer(
                coordinator: coordinator,
                selectedRoaster: $selectedRoaster,
                context: context,
                selectedTab: $selectedTab,
                navigationPath: $navigationPath
            )
            .id("new-recipe")
        }
        .onChange(of: selectedTab) { _, newTab in
            // Clear navigation when leaving the tab
            if newTab != .add && !navigationPath.isEmpty {
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
    @Binding var navigationPath: NavigationPath
    
    @StateObject private var viewModel: AddRecipeViewModel
    
    init(coordinator: AddRecipeCoordinator,
         selectedRoaster: Binding<Roaster?>,
         context: NSManagedObjectContext,
         selectedTab: Binding<MainView.Tab>,
         navigationPath: Binding<NavigationPath>) {
        
        self.coordinator = coordinator
        self._selectedRoaster = selectedRoaster
        self.context = context
        self._selectedTab = selectedTab
        self._navigationPath = navigationPath
        
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster.wrappedValue,
            context: context
        )
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        AddRecipe(
            selectedTab: $selectedTab,
            viewModel: viewModel,
            navigationPath: $navigationPath
        )
        .navigationDestination(for: AddRecipeNavigation.self) { destination in
            switch destination {
            case .stages(let formData, _):
                GlobalBackground {
                    StagesManagementViewWrapper(
                        initialFormData: formData,
                        brewMath: viewModel.brewMath,
                        selectedTab: $selectedTab,
                        context: context,
                        existingRecipeID: nil,
                        onFormDataUpdate: { updatedFormData in
                            viewModel.formData = updatedFormData
                        }
                    )
                }
            }
        }
        .onAppear {
            coordinator.setViewModel(viewModel)
            viewModel.onNavigateToStages = { formData, _ in
                navigationPath.append(AddRecipeNavigation.stages(formData: formData, existingRecipeID: nil))
            }
        }
        .onChange(of: selectedRoaster) { _, newValue in
            viewModel.updateSelectedRoaster(newValue)
        }
    }
}