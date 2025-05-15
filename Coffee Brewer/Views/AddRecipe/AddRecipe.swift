import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: MainView.Tab
        
    @ObservedObject private var recipe: Recipe
    @State private var searchText: String = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var allRoasters: FetchedResults<Roaster>
    
    enum FocusedField: Hashable {
        case roaster, name, grams, ratio, temperature
    }
    @State private var focusedField: FocusedField? = nil

    private let roaster: Roaster
    
    init(existingRoaster: Roaster? = nil, context: NSManagedObjectContext, selectedTab: Binding<MainView.Tab>) {
        _selectedTab = selectedTab

        self.roaster = existingRoaster ?? Roaster(context: context)

        // Create draft Recipe in memory
        let draft = Recipe(context: context)
        draft.roaster = roaster
        draft.name = ""
        draft.grams = 18
        draft.ratio = 16
        draft.temperature = 95.0
        draft.lastBrewedAt = Date()

        _recipe = ObservedObject(wrappedValue: draft)
    }
    
    var filteredRoasters: [Roaster] {
        let result = allRoasters.filter {
            searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        print("Search Text: \(searchText)")
        print("All Roasters:")
        allRoasters.forEach { print("- \($0.name ?? "Unnamed")") }
        print("Filtered Roasters:")
        result.forEach { print("- \($0.name ?? "Unnamed")") }

        return result
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
                        )
                        
                        FormTextField(
                            title: "Recipe Name",
                            text: Binding(
                                get: { recipe.name ?? "" },
                                set: { recipe.name = $0 }
                            ),
                            focusedField: $focusedField,
                            field: .name
                        )
                        
                        ExpandableNumberField(
                            title: "Coffee (grams)",
                            value: Binding(
                                get: {recipe.grams},
                                set: {recipe.grams = $0}
                            ),
                            range: Array(8...40),
                            formatter: { "\($0)g" },
                            focusedField: $focusedField,
                            field: .grams,
                        )
                        
                        ExpandableNumberField(
                            title: "Ratio",
                            value: Binding(
                                get: {recipe.ratio},
                                set: {recipe.ratio = $0}
                            ),
                            range: Array(10...20),
                            formatter: { "1:\($0)" },
                            focusedField: $focusedField,
                            field: .ratio,
                        )
                        
                        ExpandableNumberField(
                            title: "Water Temperature",
                            value: Binding(
                                get: {recipe.temperature},
                                set: {recipe.temperature = $0}
                            ),
                            range: Array(stride(from: 80.0, through: 99.5, by: 0.5)),
                            formatter: { "\($0)°C" },
                            focusedField: $focusedField,
                            field: .temperature,
                        )
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        SecondaryHeader(title: "Grinder")
                            .padding(.bottom, 10)

//                        ExpandableNumberField(
//                            title: "Grind Size",
//                            value: $viewModel.form.grindSize,
//                            range: Array(0...100),
//                            formatter: { "\($0)" }
//                        )
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
