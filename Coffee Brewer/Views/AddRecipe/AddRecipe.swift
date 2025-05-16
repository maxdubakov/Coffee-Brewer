import SwiftUI
import CoreData

struct AddRecipe: View {
    // MARK: - Nested Types
    enum FocusedField: Hashable {
        case roaster, name, grams, ratio, temperature, grindSize
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
    
    // MARK: - Constants
    private let roaster: Roaster?
    private let grinder: Grinder? = nil

    init(existingRoaster: Roaster? = nil, context: NSManagedObjectContext, selectedTab: Binding<MainView.Tab>) {
        _selectedTab = selectedTab

        self.roaster = existingRoaster
        let draft = Recipe(context: context)
        draft.roaster = roaster
        draft.name = ""
        draft.grams = 18
        draft.ratio = 16.0
        draft.temperature = 95.0
        draft.grindSize = 40
        draft.lastBrewedAt = Date()

        _recipe = ObservedObject(wrappedValue: draft)
    }

    var body: some View {
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
                        
                        FormTextField(
                            title: "Recipe Name",
                            field: .name,
                            text: Binding(
                                get: { recipe.name ?? "" },
                                set: { recipe.name = $0 }
                            ),
                            focusedField: $focusedField,
                        )
                        
                        FormExpandableNumberField(
                            title: "Coffee (grams)",
                            range: Array(8...40),
                            formatter: { "\($0)g" },
                            field: .grams,
                            value: Binding(
                                get: {recipe.grams},
                                set: {recipe.grams = $0}
                            ),
                            focusedField: $focusedField,
                        )
                        
                        FormExpandableNumberField(
                            title: "Ratio",
                            range: Array(stride(from: 10.0, through: 20.0, by: 1.0)),
                            formatter: { "1:\($0)" },
                            field: .ratio,
                            value: Binding(
                                get: {recipe.ratio},
                                set: {recipe.ratio = $0}
                            ),
                            focusedField: $focusedField,
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
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 18, bottom: 28, trailing: 18))
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    recipe.lastBrewedAt = Date()
                    do {
                        try viewContext.save()
                        selectedTab = .home
                    } catch {
                        print("Failed to save recipe: \(error)")
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 14.5, leading: 16, bottom: 14.5, trailing: 16))
                        .background(BrewerColors.coffee)
                        .cornerRadius(48)
                }
            }
            .padding(18)
        }
    }
}

#Preview {
    GlobalBackground {
        AddRecipe(
            context: PersistenceController.preview.container.viewContext,
            selectedTab: .constant(.add)
        )
    }
}
