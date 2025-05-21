import SwiftUI
import CoreData

struct AddRecipe: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Bindings
    @Binding var selectedTab: MainView.Tab
    
    // MARK: - Observed Objects
    @ObservedObject private var recipe: Recipe
    
    // MARK: - State
    @State private var focusedField: FocusedField? = nil
    @State private var navigateToStages: Bool = false
    @StateObject private var brewMath: BrewMathViewModel
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var selectedRoaster: Roaster?
    
    // MARK: - Constants
    private let isEditing: Bool
    
    init(existingRoaster: Roaster? = nil, context: NSManagedObjectContext, selectedTab: Binding<MainView.Tab>, existingRecipe: Recipe? = nil) {
        _selectedTab = selectedTab
        isEditing = existingRecipe != nil
        
        if let recipe = existingRecipe {
            _recipe = ObservedObject(wrappedValue: recipe)
            _selectedRoaster = State(initialValue: recipe.roaster)
            // Initialize BrewMath with existing recipe values
            _brewMath = StateObject(wrappedValue: BrewMathViewModel(
                grams: recipe.grams,
                ratio: recipe.ratio,
                water: recipe.waterAmount
            ))
        } else {
            // Create a new recipe
            let draft = Recipe(context: context)
            draft.id = UUID()
            draft.name = "New Recipe"
            draft.temperature = 95.0
            draft.grindSize = 40
            
            _recipe = ObservedObject(wrappedValue: draft)
            // Initialize BrewMath with default values
            _brewMath = StateObject(wrappedValue: BrewMathViewModel(
                grams: 18,
                ratio: 16.0,
                water: 288
            ))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // MARK: - Header Section
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: isEditing ? "Edit Recipe" : "New Recipe")
                        
                        Text("Create a custom coffee recipe with precise brewing parameters.")
                            .font(.subheadline)
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    .padding(.horizontal, 18)
                    
                    // MARK: - Roaster & Recipe Name Section
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
                                selectedRoaster: $selectedRoaster,
                                focusedField: $focusedField
                            )

                            Divider()
                            
                            FormKeyboardInputField(
                                title: "Recipe Name",
                                field: .name,
                                keyboardType: .default,
                                valueToString: { $0 },
                                stringToValue: { $0 },
                                value: Binding(
                                    get: { recipe.name ?? "" },
                                    set: { recipe.name = $0 }
                                ),
                                focusedField: $focusedField
                            )
                        }
                    }
                    
                    // MARK: - Brewing Parameters Section
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(BrewerColors.caramel)
                                .font(.system(size: 16))
                            
                            SecondaryHeader(title: "Brewing Parameters")
                        }
                        .padding(.horizontal, 20)
                        
                        // Coffee parameters card
                        FormGroup {
                            // Coffee grams
                            FormExpandableNumberField(
                                title: "Coffee (grams)",
                                range: Array(8...40),
                                formatter: { "\($0)g" },
                                field: .grams,
                                value: $brewMath.grams,
                                focusedField: $focusedField
                            )
                            
                            Divider()
                            
                            // Ratio
                            FormExpandableNumberField(
                                title: "Ratio",
                                range: Array(stride(from: 10.0, through: 20.0, by: 1.0)),
                                formatter: { "1:\($0)" },
                                field: .ratio,
                                value: $brewMath.ratio,
                                focusedField: $focusedField
                            )
                            
                            Divider()
                            
                            // Water
                            FormKeyboardInputField(
                                title: "Water (ml)",
                                field: .waterml,
                                keyboardType: .numberPad,
                                valueToString: { String($0) },
                                stringToValue: { Int16($0) },
                                value: $brewMath.water,
                                focusedField: $focusedField
                            )
                            
                            Divider()
                            
                            FormExpandableNumberField(
                                title: "Temperature",
                                range: Array(stride(from: 80.0, through: 99.5, by: 0.5)),
                                formatter: { "\($0)°C" },
                                field: .temperature,
                                value: Binding(
                                    get: { recipe.temperature },
                                    set: { recipe.temperature = $0 }
                                ),
                                focusedField: $focusedField
                            )
                        }
                    }
                    
                    // MARK: - Grinder Section
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.grid.3x3")
                                .foregroundColor(BrewerColors.caramel)
                                .font(.system(size: 16))
                            
                            SecondaryHeader(title: "Grind")
                        }
                        .padding(.horizontal, 20)
                        
                        // Grinder card
                        FormGroup {
                            SearchGrinderPicker(
                                selectedGrinder: Binding(
                                    get: { recipe.grinder },
                                    set: { recipe.grinder = $0 }
                                ),
                                focusedField: $focusedField
                            )
                            
                            Divider()
                            
                            FormExpandableNumberField(
                                title: "Grind Size",
                                range: Array(0...100),
                                formatter: { "\($0)" },
                                field: .grindSize,
                                value: Binding(
                                    get: { recipe.grindSize },
                                    set: { recipe.grindSize = $0 }
                                ),
                                focusedField: $focusedField
                            )
                        }
                    }
                    
                    // MARK: - Continue Button
                    VStack(spacing: 12) {
                        StandardButton(
                            title: "Continue to Stages",
                            iconName: "arrow.right.circle.fill",
                            action: {
                                validateAndContinue()
                            },
                            style: .primary
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.top, 10)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(BrewerColors.background)
            .alert(isPresented: $showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $navigateToStages) {
                GlobalBackground {
                    StagesManagementView(
                        recipe: recipe,
                        brewMath: brewMath,
                        selectedTab: $selectedTab
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func validateAndContinue() {
        // Validate recipe information before proceeding to stages
        var missingFields: [String] = []
        
        if recipe.name?.isEmpty ?? true {
            missingFields.append("Recipe Name")
        }
        
        if selectedRoaster == nil {
            missingFields.append("Roaster")
        }
        
        if missingFields.isEmpty {
            // Update recipe with brew math values before navigating
            recipe.roaster = selectedRoaster
            recipe.grams = brewMath.grams
            recipe.ratio = brewMath.ratio
            recipe.waterAmount = brewMath.water
            
            // Save context before navigating to ensure data is persisted
            do {
                try viewContext.save()
                navigateToStages = true
            } catch {
                validationMessage = "Error saving recipe: \(error.localizedDescription)"
                showValidationAlert = true
            }
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    return AddRecipe(
        context: context,
        selectedTab: .constant(.add)
    )
    .environment(\.managedObjectContext, context)
    .background(BrewerColors.background)
}
