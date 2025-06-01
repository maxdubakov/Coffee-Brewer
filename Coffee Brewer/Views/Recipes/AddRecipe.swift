import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coordinator: AddRecipeCoordinator
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    @Binding var selectedRoaster: Roaster?
    @Binding var selectedGrinder: Grinder?
    
    @StateObject private var viewModel: AddRecipeViewModel
    
    init(selectedRoaster: Binding<Roaster?>, selectedGrinder: Binding<Grinder?>, context: NSManagedObjectContext) {
        self._selectedRoaster = selectedRoaster
        self._selectedGrinder = selectedGrinder
        
        let vm = AddRecipeViewModel(
            selectedRoaster: selectedRoaster.wrappedValue,
            selectedGrinder: selectedGrinder.wrappedValue,
            context: context
        )
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        FixedBottomLayout(
                content: {
                    VStack(spacing: 16) {
                        PageTitleH2("Add Recipe", subtitle: "Create a custom coffee brewing recipe")

                        RecipeForm(
                            formData: $viewModel.formData,
                            brewMath: $viewModel.brewMath,
                            focusedField: $viewModel.focusedField
                        )
                    }
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
        .onChange(of: selectedRoaster) { _, newValue in
            // Update viewModel when selectedRoaster changes externally
            viewModel.updateSelectedRoaster(newValue)
        }
        .onAppear {
            // Set navigation callback to use NavigationCoordinator
            viewModel.onNavigateToStages = { formData, existingRecipeID in
                navigationCoordinator.addPath.append(AppDestination.stageChoice(formData: formData, existingRecipeID: existingRecipeID))
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
    @Previewable @State var selectedRoaster: Roaster? = nil
    @Previewable @State var selectedGrinder: Grinder? = nil
    let preview = PersistenceController.preview
    
    return AddRecipe(
        selectedRoaster: $selectedRoaster,
        selectedGrinder: $selectedGrinder,
        context: preview.container.viewContext
    )
    .environmentObject(AddRecipeCoordinator())
    .environmentObject(NavigationCoordinator())
    .environment(\.managedObjectContext, preview.container.viewContext)
}


