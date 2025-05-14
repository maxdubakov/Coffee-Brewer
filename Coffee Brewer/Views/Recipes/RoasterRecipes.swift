import SwiftUI
import CoreData

struct RoasterRecipes: View {
    @ObservedObject var roaster: Roaster
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var recipes: [Recipe] = []
    
    private func fetchRecipes() {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "roaster == %@", roaster)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)]

        do {
            recipes = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching recipes: \(error.localizedDescription)")
            recipes = []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            recipeScroll
        }
        .onAppear(perform: fetchRecipes)
    }
    
    private var header: some View {
        HStack {
            SecondaryHeader(title: roaster.name ?? "Unknown Roaster")
            Spacer()
            Button(action: {print("Add clicked")}) {
                Image(systemName: "plus.circle")
                    .foregroundColor(BrewerColors.textPrimary)
            }
        }
        .padding(.top, 34)
        .padding(.horizontal, 20)
    }
    
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
