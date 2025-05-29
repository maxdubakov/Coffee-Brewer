import SwiftUI
import CoreData

struct GrinderGroupedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let navigationCoordinator: NavigationCoordinator
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    )
    private var grinders: FetchedResults<Grinder>
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(grinders) { grinder in
                if let recipes = grinder.recipes?.allObjects as? [Recipe], !recipes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: grinder.typeIcon)
                                .font(.subheadline)
                                .foregroundColor(BrewerColors.caramel)
                            
                            Text(grinder.name ?? "Unknown Grinder")
                                .font(.headline)
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            Spacer()
                            
                            Text.pluralized("recipe", count: recipes.count)
                                .font(.caption)
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recipes.sorted(by: { ($0.lastBrewedAt ?? Date.distantPast) > ($1.lastBrewedAt ?? Date.distantPast) })) { recipe in
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
                        }
                    }
                }
            }
        }
    }
}
