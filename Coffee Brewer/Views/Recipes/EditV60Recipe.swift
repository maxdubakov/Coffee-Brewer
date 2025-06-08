import SwiftUI
import CoreData

struct EditV60Recipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    @Binding var isPresented: Recipe?
    
    @StateObject private var viewModel: EditRecipeViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showDiscardAlert = false
    
    init(recipe: Recipe, isPresented: Binding<Recipe?>) {
        self.recipe = recipe
        self._isPresented = isPresented
        
        // Create view model
        let context = recipe.managedObjectContext ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: EditRecipeViewModel(recipe: recipe, context: context))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            FixedBottomLayout(
                content: {
                    VStack(spacing: 16) {
                        PageTitleH2(viewModel.headerTitle, subtitle: viewModel.headerSubtitle)

                        RecipeForm(
                            content: {
                                BasicInfoSection(
                                    formData: $viewModel.formData,
                                    focusedField: $viewModel.focusedField
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if viewModel.hasUnsavedChanges() {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
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
                case .stageChoice(_, _):
                    Text("Do nothing")
                case .stages(let formData, let existingRecipeID):
                    GlobalBackground {
                        StagesManagement(
                            formData: formData,
                            brewMath: viewModel.brewMath,
                            context: viewContext,
                            existingRecipeID: existingRecipeID,
                            onSaveComplete: {
                                isPresented = nil
                            },
                            onFormDataUpdate: { updatedFormData in
                                viewModel.formData = updatedFormData
                            }
                        )
                    }
                case .recordStages(_, _):
                    Text("Do nothing")
                }
            }
        }
        .onAppear {
            viewModel.onNavigateToStages = { formData, recipeID in
                navigationPath.append(AddRecipeNavigation.stages(formData: formData, existingRecipeID: recipeID))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let recipe = PersistenceController.sampleRecipe
    
    return EditV60Recipe(recipe: recipe, isPresented: .constant(recipe))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}