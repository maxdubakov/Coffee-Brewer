import SwiftUI

struct BrewCompletionView: View {
    // MARK: - Properties
    var recipe: Recipe
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - State
    @State private var showConfetti = false
    @State private var rating: Int = 0
    @State private var notes: String = ""
    
    // MARK: - Computed Properties
    private var roasterName: String {
        recipe.roaster?.name ?? "Unknown Roaster"
    }
    
    private var recipeName: String {
        recipe.name ?? "Untitled Recipe"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image("coffee-success")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(BrewerColors.caramel)
                    .frame(width: 80, height: 80)
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
                VStack(alignment: .leading, spacing: 24) {
                    // Rating
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How was your brew?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(star <= rating ? BrewerColors.caramel : BrewerColors.textSecondary)
                                    .font(.system(size: 30))
                                    .onTapGesture {
                                        rating = star
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tasting Notes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(BrewerColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(BrewerColors.divider, lineWidth: 1)
                            )
                            .foregroundColor(BrewerColors.textPrimary)
                            .font(.system(size: 16))
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("How did it taste? (Aroma, acidity, body, etc.)")
                                            .font(.system(size: 16))
                                            .foregroundColor(BrewerColors.textSecondary.opacity(0.7))
                                            .padding(16)
                                            .allowsHitTesting(false)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            
            // Buttons
            VStack(spacing: 12) {
                StandardButton(
                    title: "Save to Journal",
                    action: saveBrewExperience,
                    style: .primary
                )
                
                StandardButton(
                    title: "Brew again",
                    action: {
//
                    },
                    style: .secondary
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(BrewerColors.background)
        .onAppear {
            // Trigger confetti animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showConfetti = true
                }
            }
        }
    }
    
    // MARK: - Methods
    private func saveBrewExperience() {
        // Here you would save the brew experience to your Core Data model
        // This is a placeholder for that implementation
        
        // Update the last brewed date if it hasn't been set already
        if recipe.lastBrewedAt == nil {
            recipe.lastBrewedAt = Date()
        }
        
        // Create a new BrewJournal entry (you would need to add this entity to your Core Data model)
        // let journalEntry = BrewJournal(context: viewContext)
        // journalEntry.rating = Int16(rating)
        // journalEntry.notes = notes
        // journalEntry.date = Date()
        // journalEntry.recipe = recipe
        
        // Save the context
        do {
            try viewContext.save()
//            dismiss()
        } catch {
            print("Failed to save brew experience: \(error)")
        }
    }
}

// For a real implementation, you might want to add a Confetti view
struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<40) { i in
                    Rectangle()
                        .fill(confettiColors.randomElement()!)
                        .frame(width: 8, height: 16)
                        .rotationEffect(.degrees(Double.random(in: 0...360)))
                        .position(
                            x: randomPosition(max: geometry.size.width),
                            y: randomPosition(max: geometry.size.height)
                        )
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            Animation.linear(duration: 3)
                                .delay(Double.random(in: 0...1)),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    private let confettiColors: [Color] = [
        BrewerColors.caramel,
        BrewerColors.amber,
        BrewerColors.cream,
        BrewerColors.coffee,
        BrewerColors.espresso
    ]
    
    private func randomPosition(max: CGFloat) -> CGFloat {
        return CGFloat.random(in: 0...max)
    }
}

// MARK: - Preview
struct BrewCompletionViewPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create a test recipe
        let testRecipe = Recipe(context: context)
        testRecipe.name = "Ethiopian Light Roast"
        testRecipe.grams = 18
        testRecipe.ratio = 16.0
        testRecipe.waterAmount = 288
        testRecipe.temperature = 94.0
        testRecipe.grindSize = 22
        
        // Create a test roaster
        let testRoaster = Roaster(context: context)
        testRoaster.name = "Bright Beans"
        testRecipe.roaster = testRoaster
        
        // Return the view
        return BrewCompletionView(recipe: testRecipe)
            .environment(\.managedObjectContext, context)
    }
}
