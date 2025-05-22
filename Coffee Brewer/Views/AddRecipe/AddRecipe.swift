import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selectedTab: MainView.Tab
    
    @ObservedObject var viewModel: AddRecipeViewModel
    
    var body: some View {
        NavigationStack {
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
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $viewModel.navigateToStages) {
                if viewModel.navigateToStages {  // Double-check the state
                    GlobalBackground {
                        StagesManagementView(
                            recipe: viewModel.getRecipe(),
                            brewMath: viewModel.brewMath,
                            selectedTab: $selectedTab
                        )
                    }
                }
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
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
        }
    }
    
    // MARK: - View Components
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
                    selectedRoaster: $viewModel.selectedRoaster,
                    focusedField: $viewModel.focusedField
                )

                Divider()
                
                FormKeyboardInputField(
                    title: "Recipe Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $viewModel.recipeName,
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
                    value: $viewModel.temperature,
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
                    selectedGrinder: $viewModel.selectedGrinder,
                    focusedField: $viewModel.focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Grind Size",
                    range: Array(0...100),
                    formatter: { "\($0)" },
                    field: .grindSize,
                    value: $viewModel.grindSize,
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
    let viewModel = AddRecipeViewModel(
        selectedRoaster: .constant(nil),
        context: context,
        existingRecipe: nil
    )
    
    return AddRecipe(
        selectedTab: .constant(.add),
        viewModel: viewModel
    )
    .environment(\.managedObjectContext, context)
    .background(BrewerColors.background)
}
