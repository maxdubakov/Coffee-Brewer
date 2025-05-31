import SwiftUI
import CoreData

struct Recipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    // MARK: - Fetch Requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
        animation: .default
    )
    private var allRecipes: FetchedResults<Recipe>
    
    // MARK: - Computed Properties
    private var featuredRecipe: Recipe? {
        allRecipes.first { $0.lastBrewedAt != nil }
    }
    
    private var quickBrewRecipes: [Recipe] {
        let recentRecipes = allRecipes
            .filter { $0.lastBrewedAt != nil }
            .prefix(10)
        
        return Array(recentRecipes)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                quickBrewSection

                RoasterGroupedView(navigationCoordinator: navigationCoordinator)
                
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .tint(BrewerColors.cream)
            .interactiveDismissDisabled()
        }
        .alert("Delete Recipe", isPresented: $navigationCoordinator.showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                navigationCoordinator.cancelDeleteRecipe()
            }
            
            Button("Delete", role: .destructive) {
                navigationCoordinator.deleteRecipe(in: viewContext)
            }
        } message: {
            Text("Are you sure you want to delete \(navigationCoordinator.recipeToDelete?.name ?? "this recipe")?")
        }
    }
    
    private var quickBrewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Brew")
                .font(.headline)
                .foregroundColor(BrewerColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickBrewRecipes) { recipe in
                        RecipeCard(
                            recipe: recipe,
                            onBrewTapped: {
                                navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
                            },
                            onEditTapped: {
                                navigationCoordinator.presentEditRecipe(recipe)
                            },
                            onDeleteTapped: {
                                navigationCoordinator.confirmDeleteRecipe(recipe)
                            },
                            onDuplicateTapped: {
                                navigationCoordinator.duplicateRecipe(recipe, in: viewContext)
                            }
                        )
                        .frame(width: 180)
                    }
                }
            }
        }
    }
    
}

#Preview {
    GlobalBackground {
        Recipes(navigationCoordinator: NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
