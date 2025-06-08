import SwiftUI
import CoreData

struct AddOreaRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coordinator: AddRecipeCoordinator
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    @Binding var selectedRoaster: Roaster?
    @Binding var selectedGrinder: Grinder?
    
    @StateObject private var viewModel: AddOreaRecipeViewModel
    
    init(selectedRoaster: Binding<Roaster?>, selectedGrinder: Binding<Grinder?>, context: NSManagedObjectContext) {
        self._selectedRoaster = selectedRoaster
        self._selectedGrinder = selectedGrinder
        
        let vm = AddOreaRecipeViewModel(
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
                        PageTitleH2(viewModel.headerTitle, subtitle: viewModel.headerSubtitle)

                        RecipeForm(
                            content: {
                                BasicInfoWithBottomTypeSection(
                                    formData: $viewModel.formData,
                                    focusedField: $viewModel.focusedField,
                                )
                                
                                BrewingParametersSection(
                                    formData: $viewModel.formData,
                                    brewMath: $viewModel.brewMath,
                                    focusedField: $viewModel.focusedField
                                )
                                
                                GrindSection(
                                    formData: $viewModel.formData,
                                    focusedField: $viewModel.focusedField
                                )
                            }
                        )
                        .onTapGesture {
                            // Dismiss any active field when tapping outside
                            withAnimation(.spring()) {
                                viewModel.focusedField = nil
                            }
                        }
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
    
    GlobalBackground {
        AddOreaRecipe(
            selectedRoaster: $selectedRoaster,
            selectedGrinder: $selectedGrinder,
            context: PersistenceController.preview.container.viewContext
        )
        .environmentObject(AddRecipeCoordinator())
        .environmentObject(NavigationCoordinator())
    }
}
