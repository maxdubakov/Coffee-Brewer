import SwiftUI
import CoreData

struct RoasterRecipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Observed Objects
    @ObservedObject var roaster: Roaster
    
    // MARK: - Fetch Requests
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    // MARK: - State
    @State private var selectedRecipeID: NSManagedObjectID?
    @State private var showBrewScreen = false
    
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
        .fullScreenCover(isPresented: $showBrewScreen) {
            if let id = selectedRecipeID,
               let brewRecipe = viewContext.object(with: id) as? Recipe {
                BrewRecipeView(recipe: brewRecipe)
            } else {
                Text("SHIT")
            }
        }
        .onChange(of: showBrewScreen) { oldValue, newValue in
            if !newValue {
                // Reset selectedRecipeID when sheet is dismissed
                selectedRecipeID = nil
            }
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
                        recipe: recipe,
                    ).onTapGesture {
                        print("Selected Recipe ID: \(recipe.objectID)")
                        selectedRecipeID = recipe.objectID
                        showBrewScreen = true
                    }
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
