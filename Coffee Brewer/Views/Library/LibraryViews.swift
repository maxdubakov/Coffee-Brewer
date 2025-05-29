import SwiftUI

// MARK: - Recipes Library View
struct RecipesLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)],
        animation: .default
    )
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingDeleteAlert = false
    @State private var recipeToDelete: Recipe?
    
    private var filteredRecipes: [Recipe] {
        let allRecipes = Array(recipes)
        print("Total recipes: \(allRecipes.count)")
        print("Search text: '\(searchText)'")
        
        if searchText.isEmpty {
            return allRecipes
        } else {
            let filtered = allRecipes.filter { recipe in
                let nameMatch = recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let roasterMatch = recipe.roaster?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let grinderMatch = recipe.grinder?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let matches = nameMatch || roasterMatch || grinderMatch
                if matches {
                    print("Match found: \(recipe.name ?? "Unknown")")
                }
                return matches
            }
            print("Filtered recipes: \(filtered.count)")
            return filtered
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if filteredRecipes.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredRecipes) { recipe in
                    RecipeLibraryRow(
                        recipe: recipe,
                        onTap: {
                            navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            recipeToDelete = recipe
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            navigationCoordinator.presentEditRecipe(recipe)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(BrewerColors.caramel)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                recipeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let recipe = recipeToDelete {
                    deleteRecipe(recipe)
                }
            }
        } message: {
            Text("Are you sure you want to delete \(recipeToDelete?.name ?? "this recipe")?")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "mug" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No recipes yet" : "No recipes found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            if searchText.isEmpty {
                Text("Create your first recipe to get started")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private func deleteRecipe(_ recipe: Recipe) {
        withAnimation {
            viewContext.delete(recipe)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
        recipeToDelete = nil
    }
}

// MARK: - Recipe Library Row
struct RecipeLibraryRow: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Recipe Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let roaster = recipe.roaster {
                            HStack(spacing: 4) {
                                if let flag = roaster.country?.flag {
                                    Text(flag)
                                        .font(.system(size: 11))
                                }
                                Text(roaster.name ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(BrewerColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                        
                        Text("\(recipe.grams)g")
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Roasters Library View
struct RoastersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Roaster Management")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BrewerColors.cream)
            
            Text("Roaster management coming soon...")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Grinders Library View
struct GrindersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Grinder Management")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BrewerColors.cream)
            
            Text("Grinder management coming soon...")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
