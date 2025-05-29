import SwiftUI
import CoreData

struct Recipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedGrouping: RecipeGrouping = .byRoaster
    
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
            .prefix(4)
        
        return Array(recentRecipes.dropFirst())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    if let featured = featuredRecipe {
                        VStack(alignment: .leading, spacing: 16) {
                            FeaturedRecipeCard(
                                recipe: featured,
                                onBrewTapped: {
                                    navigationCoordinator.navigateToBrewRecipe(recipe: featured)
                                },
                                onEditTapped: {
                                    navigationCoordinator.presentEditRecipe(featured)
                                }
                            )
                            .padding(.horizontal, 20)
                            
                            // Quick Brew Section
                            if !quickBrewRecipes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Quick Brew")
                                        .font(.headline)
                                        .foregroundColor(BrewerColors.textPrimary)
                                        .padding(.horizontal, 20)
                                    
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
                                                    }
                                                )
                                                .frame(width: 180)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Grouping Filter
                    RecipeGroupFilter(selectedGrouping: $selectedGrouping)
                        .padding(.top, 8)
                    
                    // Filtered Content
                    Group {
                        switch selectedGrouping {
                        case .favorites:
                            Text("Favorites coming soon")
                                .foregroundColor(BrewerColors.textSecondary)
                                .padding(.top, 40)
                        case .byRoaster:
                            RoasterGroupedView(navigationCoordinator: navigationCoordinator)
                        case .byGrinder:
                            GrinderGroupedView(navigationCoordinator: navigationCoordinator)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .tint(BrewerColors.cream)
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
}

#Preview {
    GlobalBackground {
        Recipes(navigationCoordinator: NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
