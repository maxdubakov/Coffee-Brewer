import SwiftUI
import CoreData

struct RoasterGroupedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let navigationCoordinator: NavigationCoordinator
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )
    private var roasters: FetchedResults<Roaster>
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(roasters) { roaster in
                if let recipes = roaster.recipes?.allObjects as? [Recipe], !recipes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            if let country = roaster.country {
                                Text(country.flag ?? "")
                                    .font(.title3)
                            }
                            Text(roaster.name ?? "Unknown Roaster")
                                .font(.headline)
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recipes.sorted(by: { ($0.lastBrewedAt ?? Date.distantPast) > ($1.lastBrewedAt ?? Date.distantPast) })) { recipe in
                                    PremiumRecipeCard(
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
                        .padding(.horizontal, -20)
                    }
                }
            }
        }
    }
}