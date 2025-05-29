import SwiftUI
import CoreData

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
    @State private var isEditMode = false
    @State private var selectedRecipes: Set<NSManagedObjectID> = []
    
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
            // Header with edit/delete buttons
            if !filteredRecipes.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedRecipes.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedRecipes.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredRecipes.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredRecipes) { recipe in
                    RecipeLibraryRow(
                        recipe: recipe,
                        isEditMode: isEditMode,
                        isSelected: selectedRecipes.contains(recipe.objectID),
                        onTap: {
                            if isEditMode {
                                toggleSelection(for: recipe)
                            } else {
                                navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
                            }
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
        .alert("Delete Recipe\(selectedRecipes.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedRecipes.isEmpty {
                    recipeToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedRecipes.isEmpty {
                    deleteSelectedRecipes()
                } else if let recipe = recipeToDelete {
                    deleteRecipe(recipe)
                }
            }
        } message: {
            if !selectedRecipes.isEmpty {
                Text("Are you sure you want to delete \(selectedRecipes.count) recipe\(selectedRecipes.count == 1 ? "" : "s")?")
            } else {
                Text("Are you sure you want to delete \(recipeToDelete?.name ?? "this recipe")?")
            }
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
    
    private func toggleSelection(for recipe: Recipe) {
        if selectedRecipes.contains(recipe.objectID) {
            selectedRecipes.remove(recipe.objectID)
        } else {
            selectedRecipes.insert(recipe.objectID)
        }
    }
    
    private func deleteSelectedRecipes() {
        withAnimation {
            for objectID in selectedRecipes {
                if let recipe = viewContext.object(with: objectID) as? Recipe {
                    viewContext.delete(recipe)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting recipes: \(error)")
            }
            
            selectedRecipes.removeAll()
            isEditMode = false
        }
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
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Selection circle (shown in edit mode)
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
                
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
                
                // Chevron (hidden in edit mode)
                if !isEditMode {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
                }
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
