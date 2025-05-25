import SwiftUI
import CoreData

struct EditRecipeView: View {
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
                    headerSection
                    basicInfoSection
                    brewingParametersSection
                    grindSection
                    continueButton
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
                        StagesManagementViewWrapper(
                            initialFormData: formData,
                            brewMath: viewModel.brewMath,
                            selectedTab: .constant(.home),
                            context: viewContext,
                            existingRecipeID: existingRecipeID,
                            onFormDataUpdate: { updatedFormData in
                                viewModel.formData = updatedFormData
                            },
                            onSaveComplete: {
                                isPresented = nil
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
    
    // MARK: - View Components (Reusing from AddRecipe)
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: viewModel.headerTitle)
            
            Text(viewModel.headerSubtitle)
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
        }
        .padding(.horizontal, 18)
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Basic Info")
            }
            .padding(.horizontal, 20)

            FormGroup {
                SearchRoasterPicker(
                    selectedRoaster: $viewModel.formData.roaster,
                    focusedField: $viewModel.focusedField
                )

                Divider()
                
                FormKeyboardInputField(
                    title: "Recipe Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $viewModel.formData.name,
                    focusedField: $viewModel.focusedField
                )
            }
        }
    }
    
    private var brewingParametersSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Brewing Parameters")
            }
            .padding(.horizontal, 20)
            
            FormGroup {
                FormExpandableNumberField(
                    title: "Coffee (grams)",
                    range: Array(8...40),
                    formatter: { "\($0)g" },
                    field: .grams,
                    value: $viewModel.brewMath.grams,
                    focusedField: $viewModel.focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Ratio",
                    range: Array(stride(from: 10.0, through: 20.0, by: 1.0)),
                    formatter: { "1:\($0)" },
                    field: .ratio,
                    value: $viewModel.brewMath.ratio,
                    focusedField: $viewModel.focusedField
                )
                
                Divider()
                
                FormKeyboardInputField(
                    title: "Water (ml)",
                    field: .waterml,
                    keyboardType: .numberPad,
                    valueToString: { String($0) },
                    stringToValue: { Int16($0) ?? 0 },
                    value: $viewModel.brewMath.water,
                    focusedField: $viewModel.focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Temperature",
                    range: Array(stride(from: 80.0, through: 99.5, by: 0.5)),
                    formatter: { "\($0)°C" },
                    field: .temperature,
                    value: $viewModel.formData.temperature,
                    focusedField: $viewModel.focusedField
                )
            }
        }
    }
    
    private var grindSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "circle.grid.3x3")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Grind")
            }
            .padding(.horizontal, 20)
            
            FormGroup {
                SearchGrinderPicker(
                    selectedGrinder: $viewModel.formData.grinder,
                    focusedField: $viewModel.focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Grind Size",
                    range: Array(0...100),
                    formatter: { "\($0)" },
                    field: .grindSize,
                    value: $viewModel.formData.grindSize,
                    focusedField: $viewModel.focusedField
                )
            }
        }
    }
    
    private var continueButton: some View {
        VStack(spacing: 12) {
            StandardButton(
                title: viewModel.continueButtonTitle,
                iconName: "arrow.right.circle.fill",
                action: viewModel.validateAndContinue,
                style: .primary
            )
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let recipe = PersistenceController.sampleRecipe
    
    return EditRecipeView(recipe: recipe, isPresented: .constant(recipe))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}