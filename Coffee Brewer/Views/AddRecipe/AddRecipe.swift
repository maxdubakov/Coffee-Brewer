import SwiftUI
import CoreData

struct AddRecipe: View {
    // MARK: - Nested Types
    enum FocusedField: Hashable {
        case roaster, name, grams, ratio, waterml, temperature, grindSize, seconds, stageWaterAmount, stageType
    }

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Bindings
    @Binding var selectedTab: MainView.Tab
    
    // MARK: - Observed Objects
    @ObservedObject private var recipe: Recipe
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var focusedField: FocusedField? = nil
    @StateObject private var brewMath = BrewMathViewModel(
        grams: 18,
        ratio: 16.0,
        water: 288
    )
    
    // MARK: - Constants
    private let roaster: Roaster?
    private let grinder: Grinder? = nil
    private let isEditing: Bool

    init(existingRoaster: Roaster? = nil, context: NSManagedObjectContext, selectedTab: Binding<MainView.Tab>, existingRecipe: Recipe? = nil) {
        _selectedTab = selectedTab
        self.roaster = existingRoaster
        isEditing = existingRecipe != nil

        if let recipe = existingRecipe {
            _recipe = ObservedObject(wrappedValue: recipe)
        } else {
            let draft = Recipe(context: context)
            draft.roaster = roaster
            draft.name = "New Recipe"
            draft.temperature = 95.0
            draft.grindSize = 40

            _recipe = ObservedObject(wrappedValue: draft)
            draft.createDefaultStage(context: context)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: "Add Recipe")
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 0) {
                            SecondaryHeader(title: "General")
                                .padding(.bottom, 10)
                            
                            SearchRoasterPicker(
                                selectedRoaster: Binding(
                                    get: { recipe.roaster },
                                    set: { recipe.roaster = $0 }
                                ),
                                focusedField: $focusedField,
                            )
                            
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
                            
                            FormExpandableNumberField(
                                title: "Coffee (grams)",
                                range: Array(8...40),
                                formatter: { "\($0)g" },
                                field: .grams,
                                value: $brewMath.grams,
                                focusedField: $focusedField,
                            )
                            
                            FormExpandableNumberField(
                                title: "Ratio",
                                range: Array(stride(from: 10.0, through: 20.0, by: 1.0)),
                                formatter: { "1:\($0)" },
                                field: .ratio,
                                value: $brewMath.ratio,
                                focusedField: $focusedField,
                            )
                            
                            FormKeyboardInputField(
                                title: "Water (ml)",
                                field: .waterml,
                                keyboardType: .default,
                                valueToString: { String($0) },
                                stringToValue: { Int16($0) },
                                value: $brewMath.water,
                                focusedField: $focusedField
                            )

                            
                            FormExpandableNumberField(
                                title: "Water Temperature",
                                range: Array(stride(from: 80.0, through: 99.5, by: 0.5)),
                                formatter: { "\($0)°C" },
                                field: .temperature,
                                value: Binding(
                                    get: {recipe.temperature},
                                    set: {recipe.temperature = $0}
                                ),
                                focusedField: $focusedField,
                            )
                        }
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            SecondaryHeader(title: "Grinder")
                                .padding(.bottom, 10)
                            
                            SearchGrinderPicker(
                                selectedGrinder: Binding(
                                    get: { recipe.grinder },
                                    set: { recipe.grinder = $0 }
                                ),
                                focusedField: $focusedField,
                            )

                            FormExpandableNumberField(
                                title: "Grind Size",
                                range: Array(0...100),
                                formatter: { "\($0)" },
                                field: .grindSize,
                                value: Binding(
                                    get: {recipe.grindSize},
                                    set: {recipe.grindSize = $0}
                                ),
                                focusedField: $focusedField,
                            )
                        }.padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 0) {
                            SecondaryHeader(title: "Stages")
                                .padding(.bottom, 10)
                            
                            StagesList(focusedField: $focusedField, recipe: recipe, brewMath: brewMath)
                                .padding(.bottom, 20)
                        }
                        
                        HStack {
                            StandardButton(
                                title: isEditing ? "Update" : "Save",
                                action: {
                                    if !isEditing {
                                        recipe.lastBrewedAt = Date()
                                    }
                                    do {
                                        recipe.grams = brewMath.grams
                                        recipe.ratio = brewMath.ratio
                                        recipe.waterAmount = brewMath.water
                                        
                                        try viewContext.save()
                                        selectedTab = .home
                                    } catch {
                                        print("Failed to save recipe: \(error)")
                                    }
                                },
                                style: .primary
                            )
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 18, bottom: 28, trailing: 18))
                }
            }
            .background(BrewerColors.background)
        }
    }
}

#Preview {
    AddRecipe(
        context: PersistenceController.preview.container.viewContext,
        selectedTab: .constant(.add)
    ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .background(BrewerColors.background)
}
