import SwiftUI
import CoreData

struct BrewCompletion: View {
    // MARK: - Properties
    var recipe: Recipe
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var focusedField: FocusedField? = nil
    @State private var showCancelAlert = false
    
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
        brew.id = UUID()
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
        
        // Copy recipe data for historical preservation
        brew.recipeName = recipe.name
        brew.recipeGrams = recipe.grams
        brew.recipeWaterAmount = recipe.waterAmount
        brew.recipeRatio = recipe.ratio
        brew.recipeTemperature = recipe.temperature
        brew.recipeGrindSize = recipe.grindSize
        brew.roasterName = recipe.roaster?.name
        brew.grinderName = recipe.grinder?.name
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                // MARK: - Header Section
                VStack(alignment: .center, spacing: 12) {
                    Text("Brew Complete!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text("\(roasterName) - \(recipeName)")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 10)

                // MARK: - Rating Section
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(BrewerColors.caramel)
                            .font(.system(size: 16))
                        
                        SecondaryHeader(title: "Rating")
                    }
                    .padding(.horizontal, 20)

                    FormRatingField(
                        field: .brewRating,
                        value: Binding(
                            get: {brew.rating},
                            set: {brew.rating = $0}
                        ),
                        focusedField: $focusedField
                    )
                    .padding(.horizontal, 18)
                    
                }
                
                // MARK: - Taste Profile Section
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(BrewerColors.caramel)
                            .font(.system(size: 16))
                        
                        SecondaryHeader(title: "Taste Profile")
                    }
                    .padding(.horizontal, 20)
                    
                    FormGroup {
                        FormSliderField(
                            value: Binding(
                                get: {Int(brew.bitterness)},
                                set: {brew.bitterness = Int16($0)}
                            ),
                            from: 0,
                            to: 10,
                            title: "Bitterness",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: {Int(brew.acidity)},
                                set: {brew.acidity = Int16($0)}
                            ),
                            from: 0,
                            to: 10,
                            title: "Acidity (Fruitiness)",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: {Int(brew.sweetness)},
                                set: {brew.sweetness = Int16($0)}
                            ),
                            from: 0,
                            to: 10,
                            title: "Sweetness",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: {Int(brew.body)},
                                set: {brew.body = Int16($0)}
                            ),
                            from: 0,
                            to: 10,
                            title: "Body",
                            color: BrewerColors.caramel
                        )
                    }
                }
                
                // MARK: - Notes Section
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .foregroundColor(BrewerColors.caramel)
                            .font(.system(size: 16))
                        
                        SecondaryHeader(title: "Tasting Notes")
                    }
                    .padding(.horizontal, 20)
                    
                    FormRichTextField(
                        notes: Binding(
                            get: {brew.notes ?? ""},
                            set: {brew.notes = $0}
                        ),
                        placeholder: "How did it taste? (Aroma, acidity, body, etc.)"
                    )
                    .padding(.horizontal, 18)
                }
                
                // MARK: - Save Button
                StandardButton(
                    title: "Save Brew Experience",
                    iconName: "checkmark.circle.fill",
                    action: saveBrewExperience,
                    style: .primary
                )
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 40)
            }
            .background(BrewerColors.background)
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showCancelAlert = true
                    }
                    .foregroundColor(BrewerColors.caramel)
                }
            }
            .alert("Discard Brew?", isPresented: $showCancelAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Your brew data will not be saved. Are you sure you want to discard it?")
            }
        }
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
struct BrewCompletionPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let testRecipe = Recipe(context: context)
        testRecipe.id = UUID()
        testRecipe.name = "Ethiopian Light Roast"
        testRecipe.grams = 18
        testRecipe.ratio = 16.0
        testRecipe.waterAmount = 288
        testRecipe.temperature = 94.0
        testRecipe.grindSize = 22
        
        let testRoaster = Roaster(context: context)
        testRoaster.id = UUID()
        testRoaster.name = "Bright Beans"
        testRecipe.roaster = testRoaster
        
        return GlobalBackground {
            BrewCompletion(recipe: testRecipe, actualElapsedTime: 10)
                .environment(\.managedObjectContext, context)
        }
    }
}
