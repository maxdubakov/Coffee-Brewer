import SwiftUI
import CoreData

struct BrewCompletionView: View {
    // MARK: - Properties
    var recipe: Recipe
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var focusedField: FocusedField? = nil
    
    // MARK: - Focus State
    @FocusState private var focusState: FocusedField?
    
    // MARK: - Private Properties
    @ObservedObject private var brew: Brew
    
    // MARK: - Computed Properties
    private var roasterName: String {
        recipe.roaster?.name ?? "Unknown Roaster"
    }
    
    private var recipeName: String {
        recipe.name ?? "Untitled Recipe"
    }
    
    private var defaultBrewName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return "\(recipeName) - \(dateFormatter.string(from: Date()))"
    }
    
    init(recipe: Recipe, actualElapsedTime: Double) {
        self.recipe = recipe
        let context = recipe.managedObjectContext ?? PersistenceController.shared.container.viewContext
        
        brew = Brew(context: context)
        brew.date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        brew.name = "\(recipe.name ?? "Untitled Recipe") - \(dateFormatter.string(from: Date()))"
        brew.rating = 0
        brew.acidity = 0
        brew.bitterness = 0
        brew.body = 0
        brew.sweetness = 0
        brew.tds = 0.0
        brew.recipe = recipe
        brew.actualDurationSeconds = Int16(actualElapsedTime)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .renderingMode(.template)
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 40))
                    .padding(.bottom, 8)
                
                Text("Brew Complete!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("\(roasterName) - \(recipeName)")
                    .font(.system(size: 18))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }
            .padding(.top, 40)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    FormKeyboardInputField(
                        title: "Brew Name",
                        field: .brewName,
                        keyboardType: .default,
                        valueToString: { $0 },
                        stringToValue: { $0 },
                        value: Binding(
                            get: { brew.name ?? "" },
                            set: { brew.name = $0 }
                        ),
                        focusedField: $focusedField
                    )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        SecondaryHeader(title: "Rating")
                        
                        FormRatingField(
                            field: .brewRating,
                            value: Binding(
                                get: {brew.rating},
                                set: {brew.rating = $0}
                            ),
                            focusedField: $focusedField,
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SecondaryHeader(title: "Taste Profile")
                        
                        VStack(alignment: .leading, spacing: 0) {
                            FormSliderField(
                                value: Binding(
                                    get: {Int(brew.bitterness)},
                                    set: {brew.bitterness = Int16($0)}
                                ),
                                from: 0,
                                to: 10,
                                title: "Bitterness",
                                color: BrewerColors.caramel,
                            )
                            
                            FormSliderField(
                                value: Binding(
                                    get: {Int(brew.acidity)},
                                    set: {brew.acidity = Int16($0)}
                                ),
                                from: 0,
                                to: 10,
                                title: "Acidity (Fruitiness)",
                                color: BrewerColors.caramel,
                            )
                            
                            FormSliderField(
                                value: Binding(
                                    get: {Int(brew.sweetness)},
                                    set: {brew.sweetness = Int16($0)}
                                ),
                                from: 0,
                                to: 10,
                                title: "Sweetness",
                                color: BrewerColors.caramel,
                            )
                            
                            FormSliderField(
                                value: Binding(
                                    get: {Int(brew.body)},
                                    set: {brew.body = Int16($0)}
                                ),
                                from: 0,
                                to: 10,
                                title: "Body",
                                color: BrewerColors.caramel,
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 30) {
                        SecondaryHeader(title: "Notes")
                        
                        FormRichTextField(
                            notes: Binding(
                                get: {brew.notes ?? ""},
                                set: {brew.notes = $0},
                            ),
                            placeholder: "How did it taste? (Aroma, acidity, body, etc.)"
                        )
                    }
                
                    StandardButton(
                        title: "Save",
                        action: saveBrewExperience,
                        style: .primary
                    )
                
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Methods
    private func saveBrewExperience() {
        recipe.lastBrewedAt = Date()
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save brew experience: \(error)")
        }
    }
}

// MARK: - Preview
struct BrewCompletionViewPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let testRecipe = Recipe(context: context)
        testRecipe.name = "Ethiopian Light Roast"
        testRecipe.grams = 18
        testRecipe.ratio = 16.0
        testRecipe.waterAmount = 288
        testRecipe.temperature = 94.0
        testRecipe.grindSize = 22
        
        let testRoaster = Roaster(context: context)
        testRoaster.name = "Bright Beans"
        testRecipe.roaster = testRoaster
        
        return GlobalBackground {
            BrewCompletionView(recipe: testRecipe, actualElapsedTime: 10)
                .environment(\.managedObjectContext, context)
        }
    }
}
