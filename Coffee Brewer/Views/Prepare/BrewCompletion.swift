import SwiftUI
import CoreData

struct BrewCompletion: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    // MARK: - State
    @StateObject private var viewModel: BrewCompletionViewModel
    @State private var showCancelAlert = false
    
    // MARK: - Focus State
    @FocusState private var focusState: FocusedField?
    
    
    init(recipe: Recipe, actualElapsedTime: Double) {
        let context = recipe.managedObjectContext ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: BrewCompletionViewModel(
            recipe: recipe,
            actualElapsedTime: actualElapsedTime,
            context: context
        ))
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
                    
                    Text("\(viewModel.roasterName) - \(viewModel.recipeName)")
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
                            get: { viewModel.formData.rating },
                            set: { viewModel.updateRating($0) }
                        ),
                        focusedField: $viewModel.focusedField
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
                                get: { Int(viewModel.formData.bitterness) },
                                set: { viewModel.updateBitterness(Int16($0)) }
                            ),
                            from: 0,
                            to: 10,
                            title: "Bitterness",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: { Int(viewModel.formData.acidity) },
                                set: { viewModel.updateAcidity(Int16($0)) }
                            ),
                            from: 0,
                            to: 10,
                            title: "Acidity (Fruitiness)",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: { Int(viewModel.formData.sweetness) },
                                set: { viewModel.updateSweetness(Int16($0)) }
                            ),
                            from: 0,
                            to: 10,
                            title: "Sweetness",
                            color: BrewerColors.caramel
                        )
                        
                        Divider()
                        
                        FormSliderField(
                            value: Binding(
                                get: { Int(viewModel.formData.body) },
                                set: { viewModel.updateBody(Int16($0)) }
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
                            get: { viewModel.formData.notes },
                            set: { viewModel.updateNotes($0) }
                        ),
                        placeholder: "How did it taste? (Aroma, acidity, body, etc.)"
                    )
                    .padding(.horizontal, 18)
                }
                
                // MARK: - Save Button
                StandardButton(
                    title: "Save Brew Experience",
                    iconName: "checkmark.circle.fill",
                    action: {
                        Task {
                            await viewModel.saveBrewExperience()
                            dismiss()
                            navigationCoordinator.popToRoot(for: .home)
                        }
                    },
                    style: .primary
                )
                .disabled(viewModel.isSaving)
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
                    // Navigate back to recipes main screen
                    navigationCoordinator.popToRoot(for: .home)
                }
            } message: {
                Text("Your brew data will not be saved. Are you sure you want to discard it?")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
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
