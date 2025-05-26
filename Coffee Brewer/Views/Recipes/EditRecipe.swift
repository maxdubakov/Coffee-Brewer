import SwiftUI
import CoreData

struct EditRecipe: View {
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
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    RecipeHeader(
                        title: viewModel.headerTitle,
                        subtitle: viewModel.headerSubtitle
                    )
                    
                    RecipeForm(
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
                case .stages(let formData, let existingRecipeID):
                    GlobalBackground {
                        StagesManagement(
                            formData: formData,
                            brewMath: viewModel.brewMath,
                            selectedTab: .constant(.home),
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
    
    return EditRecipe(recipe: recipe, isPresented: .constant(recipe))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}
