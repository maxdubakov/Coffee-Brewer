import SwiftUI
import CoreData

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Just show Recipes view directly
            Recipes(navigationCoordinator: navigationCoordinator)
        }
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                if recipe.brewMethodEnum == .oreaV4 {
                    EditOreaRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                        .environment(\.managedObjectContext, navigationCoordinator.editingRecipe?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
                } else {
                    EditV60Recipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                        .environment(\.managedObjectContext, navigationCoordinator.editingRecipe?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
                }
            }
            .tint(BrewerColors.cream)
            .interactiveDismissDisabled()
        }
        .sheet(item: $navigationCoordinator.editingRoaster) { roaster in
            NavigationStack {
                EditRoaster(roaster: roaster, isPresented: $navigationCoordinator.editingRoaster)
                    .environment(\.managedObjectContext, navigationCoordinator.editingRoaster?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
        .sheet(item: $navigationCoordinator.editingGrinder) { grinder in
            NavigationStack {
                EditGrinder(grinder: grinder, isPresented: $navigationCoordinator.editingGrinder)
                    .environment(\.managedObjectContext, navigationCoordinator.editingGrinder?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
    }
}


// MARK: - Library Content View
struct LibraryContent: View {
    let selectedTab: LibraryTab
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    var body: some View {
        Group {
            switch selectedTab {
            case .all:
                AllLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .recipes:
                RecipesLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .roasters:
                RoastersLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .grinders:
                GrindersLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .brews:
                BrewsLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            }
        }
    }
}
