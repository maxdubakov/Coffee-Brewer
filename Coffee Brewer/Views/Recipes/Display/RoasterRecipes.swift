import SwiftUI
import CoreData

struct RoasterRecipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Navigation
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    // MARK: - Observed Objects
    @ObservedObject var roaster: Roaster
    
    // MARK: - Fetch Requests
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    // MARK: - State
    @State private var showDeleteAlert = false
    @State private var recipeToDelete: Recipe?
    
    init(roaster: Roaster, navigationCoordinator: NavigationCoordinator) {
        self.roaster = roaster
        self.navigationCoordinator = navigationCoordinator
        _recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
            predicate: NSPredicate(format: "roaster == %@", roaster),
            animation: .default
        )
    }
    
    private func brew(recipe: Recipe) -> Void {
        navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
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
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .tint(BrewerColors.cream)
        }
    }
    
    // MARK: - Header View
    private var header: some View {
        HStack {
            SecondaryHeader(title: roaster.name ?? "Unknown Roaster")
            Spacer()
            Button(action: {
                navigationCoordinator.navigateToAddRecipe(roaster: roaster)
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
                            navigationCoordinator.presentEditRecipe(recipe)
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
            navigationCoordinator: NavigationCoordinator()
        )
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
