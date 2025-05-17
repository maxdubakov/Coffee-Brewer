import SwiftUI
import CoreData

struct RoasterRecipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Bindings
    @Binding var selectedTab: MainView.Tab
    @Binding var selectedRoaster: Roaster?
    
    // MARK: - Observed Objects
    @ObservedObject var roaster: Roaster
    
    // MARK: - Fetch Requests
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    // MARK: - State
    @State private var selectedRecipeID: NSManagedObjectID?
    @State private var showBrewScreen = false
    @State private var showDeleteAlert = false
    @State private var recipeToDelete: Recipe?
    
    init(roaster: Roaster, selectedTab: Binding<MainView.Tab>, selectedRoaster: Binding<Roaster?>) {
        self.roaster = roaster
        _recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
            predicate: NSPredicate(format: "roaster == %@", roaster),
            animation: .default
        )
        _selectedTab = selectedTab
        _selectedRoaster = selectedRoaster
        
    }
    
    private func brew(recipe: Recipe) -> Void {
        selectedRecipeID = recipe.objectID
        showBrewScreen = true
    }
    
    private func deleteRecipe() {
        guard let recipe = recipeToDelete else { return }
        
        // Create animations to fade out the deleted recipe
        withAnimation(.bouncy(duration: 0.5)) {
            viewContext.delete(recipe)
            
            // Save the context
            do {
                try viewContext.save()
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if recipes.count > 0 {
                header
                recipeScroll
            }
        }
        .fullScreenCover(isPresented: $showBrewScreen) {
            if let id = selectedRecipeID,
               let brewRecipe = viewContext.object(with: id) as? Recipe {
                BrewRecipeView(recipe: brewRecipe)
            }
        }
        .onChange(of: showBrewScreen) { oldValue, newValue in
            if !newValue {
                // Reset selectedRecipeID when sheet is dismissed
                selectedRecipeID = nil
            }
        }
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                recipeToDelete = nil
            }
            
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
        } message: {
            Text("Are you sure you want to delete \(recipeToDelete?.name ?? "this recipe")?")
        }
    }
    
    // MARK: - Header View
    private var header: some View {
        HStack {
            SecondaryHeader(title: roaster.name ?? "Unknown Roaster")
            Spacer()
            Button(action: {
                selectedRoaster = roaster
                selectedTab = .add
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(BrewerColors.textPrimary)
            }
        }
        .padding(.top, 34)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Recipes Scroll View
    private var recipeScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                ForEach(recipes, id: \.self) { recipe in
                    RecipeCard(
                        recipe: recipe,
                        onBrewTapped: {
                            brew(recipe: recipe)
                        },
                        onEditTapped: {
                            print("Editing")
                        },
                        onDeleteTapped: {
                            recipeToDelete = recipe
                            showDeleteAlert = true
                        }
                    ).onTapGesture {
                        brew(recipe: recipe)
                    }
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    GlobalBackground {
        RoasterRecipes(
            roaster: PersistenceController.sampleRoaster,
            selectedTab: .constant(.home),
            selectedRoaster: .constant(nil)
        )
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
