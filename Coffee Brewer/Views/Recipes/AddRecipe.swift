import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coordinator: AddRecipeCoordinator
    
    @Binding var selectedTab: Main.Tab
    @Binding var selectedRoaster: Roaster?
    
    @StateObject private var viewModel: AddRecipeViewModel
    @State private var navigationPath = NavigationPath()
    
    init(selectedTab: Binding<Main.Tab>, selectedRoaster: Binding<Roaster?>, context: NSManagedObjectContext) {
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
            FixedBottomLayout(
                content: {
                    RecipeForm(
                        formData: $viewModel.formData,
                        brewMath: $viewModel.brewMath,
                        focusedField: $viewModel.focusedField
                    )
                },
                actions: {
                    StandardButton(
                        title: viewModel.continueButtonTitle,
                        iconName: "arrow.right.circle.fill",
                        action: viewModel.validateAndContinue,
                        style: .primary
                    )
                }
            )
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
                case .stageChoice(let formData, let existingRecipeID):
                    GlobalBackground {
                        StageCreationChoice(
                            onManualChoice: {
                                navigationPath.append(AddRecipeNavigation.stages(formData: formData, existingRecipeID: existingRecipeID))
                            },
                            onRecordChoice: {
                                navigationPath.append(AddRecipeNavigation.recordStages(formData: formData, existingRecipeID: existingRecipeID))
                            }
                        )
                    }
                case .stages(let formData, _):
                    GlobalBackground {
                        StagesManagement(
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
                case .recordStages(let formData, let existingRecipeID):
                    GlobalBackground {
                        RecordStages(
                            formData: formData,
                            brewMath: viewModel.brewMath,
                            selectedTab: $selectedTab,
                            context: viewContext,
                            existingRecipeID: existingRecipeID
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
                navigationPath.append(AddRecipeNavigation.stageChoice(formData: formData, existingRecipeID: nil))
            }
            // Register viewModel with coordinator
            coordinator.setViewModel(viewModel)
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        return viewModel.hasUnsavedChanges()
    }
    
    func resetIfNeeded() {
        viewModel.resetToDefaults()
    }
}

#Preview {
    @Previewable @State var selectedTab = Main.Tab.add
    @Previewable @State var selectedRoaster: Roaster? = nil
    let preview = PersistenceController.preview
    
    return AddRecipe(
        selectedTab: $selectedTab,
        selectedRoaster: $selectedRoaster,
        context: preview.container.viewContext
    )
    .environmentObject(AddRecipeCoordinator())
    .environment(\.managedObjectContext, preview.container.viewContext)
}


