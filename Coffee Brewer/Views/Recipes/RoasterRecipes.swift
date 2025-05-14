import SwiftUI
import CoreData

struct RoasterRecipes: View {
    @ObservedObject var roaster: Roaster
    @Environment(\.managedObjectContext) private var viewContext
    
    // This computed property fetches recipes for this specific roaster
    private var recipes: [Recipe] {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "roaster == %@", roaster)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(roaster.name ?? "Unknown Roaster")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(BrewerColors.textPrimary)
                
                Spacer()
                
                Button(action: addRecipe) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(BrewerColors.textPrimary)
                }
            }
            .padding(.top, 34)
            .padding(.horizontal, 20)

            // Recipe Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(recipes, id: \.self) { recipe in
                        RecipeCard(
                            title: recipe.name ?? "Untitled",
                            timeAgo: timeAgoString(from: recipe.lastBrewedAt ?? Date()),
                            onTap: {
                                // Handle recipe selection
                                print("Selected \(recipe.name ?? "Untitled") recipe")
                            }
                        )
                    }
                }
                .padding(20)
            }
        }
    }
    
    private func addRecipe() {
        withAnimation {
            // You could show a modal or sheet here to enter recipe details
            let newRecipe = Recipe(context: viewContext)
            newRecipe.name = "New Recipe"
            newRecipe.grams = 18
            newRecipe.lastBrewedAt = Date()
            newRecipe.roaster = roaster
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving new recipe: \(error)")
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
}


#Preview {
    GlobalBackground {
        RoasterRecipes(roaster: PersistenceController.sampleRoaster)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
