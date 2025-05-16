import SwiftUI
import CoreData

struct RoasterRecipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Observed Objects
    @ObservedObject var roaster: Roaster
    
    // MARK: - Fetch Requests
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    init(roaster: Roaster) {
        self.roaster = roaster
        _recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
            predicate: NSPredicate(format: "roaster == %@", roaster),
            animation: .default
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            recipeScroll
        }
    }
    
    // MARK: - Header View
    private var header: some View {
        HStack {
            SecondaryHeader(title: roaster.name ?? "Unknown Roaster")
            Spacer()
            Button(action: {print("do nothing yet")}) {
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
                        title: recipe.name ?? "Untitled",
                        timeAgo: (recipe.lastBrewedAt ?? Date()).timeAgoDescription(),
                        onTap: {
                            print("Selected \(recipe.name ?? "Untitled") recipe")
                        }
                    )
                }
            }
            .padding(20)
        }
    }
}


#Preview {
    GlobalBackground {
        RoasterRecipes(roaster: PersistenceController.sampleRoaster)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
