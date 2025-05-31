import SwiftUI
import CoreData

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
                List(Array(filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                    VStack(spacing: 0) {
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
                        
                        if index < filteredRecipes.count - 1 {
                            CustomDivider()
                                .padding(.leading, 32)
                        }
                    }
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
                        
                        Button {
                            navigationCoordinator.duplicateRecipe(recipe, in: viewContext)
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        .tint(BrewerColors.mocha)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
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
