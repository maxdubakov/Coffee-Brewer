import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selectedTab: MainView.Tab
    @Binding var selectedRoaster: Roaster?
    
    @StateObject private var viewModel: AddRecipeViewModel
    @State private var navigationPath = NavigationPath()
    
    init(selectedTab: Binding<MainView.Tab>, selectedRoaster: Binding<Roaster?>, context: NSManagedObjectContext) {
        self._selectedTab = selectedTab
        self._selectedRoaster = selectedRoaster
        
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster.wrappedValue,
            context: context
        )
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    RecipeHeaderView(
                        title: viewModel.headerTitle,
                        subtitle: viewModel.headerSubtitle
                    )
                    
                    RecipeFormView(
                        formData: $viewModel.formData,
                        brewMath: $viewModel.brewMath,
                        focusedField: $viewModel.focusedField
                    )
                    
                    RecipeContinueButton(
                        title: viewModel.continueButtonTitle,
                        action: viewModel.validateAndContinue
                    )
                }
                .padding(.top, 10)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(BrewerColors.background)
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.caramel))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .navigationDestination(for: AddRecipeNavigation.self) { destination in
                switch destination {
                case .stages(let formData, _):
                    GlobalBackground {
                        StagesManagementView(
                            formData: formData,
                            brewMath: viewModel.brewMath,
                            selectedTab: $selectedTab,
                            context: viewContext,
                            existingRecipeID: nil,
                            onFormDataUpdate: { updatedFormData in
                                viewModel.formData = updatedFormData
                            }
                        )
                    }
                }
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            // Clear navigation when leaving the tab
            if newTab != .add && !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
            }
        }
        .onChange(of: selectedRoaster) { _, newValue in
            // Update viewModel when selectedRoaster changes externally
            viewModel.updateSelectedRoaster(newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: .recipeSaved)) { _ in
            // Clear navigation after saving
            if !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
            }
        }
        .onAppear {
            // Set navigation callback
            viewModel.onNavigateToStages = { formData, _ in
                navigationPath.append(AddRecipeNavigation.stages(formData: formData, existingRecipeID: nil))
            }
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        return viewModel.hasUnsavedChanges()
    }
    
    func resetIfNeeded() {
        viewModel.resetToDefaults()
    }
}
