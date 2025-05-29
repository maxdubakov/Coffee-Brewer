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
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )
    private var roasters: FetchedResults<Roaster>
    
    @State private var showingDeleteAlert = false
    @State private var roasterToDelete: Roaster?
    @State private var isEditMode = false
    @State private var selectedRoasters: Set<NSManagedObjectID> = []
    @State private var selectedRoasterForDetail: Roaster?
    
    private var filteredRoasters: [Roaster] {
        let allRoasters = Array(roasters)
        
        if searchText.isEmpty {
            return allRoasters
        } else {
            return allRoasters.filter { roaster in
                let nameMatch = roaster.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let countryMatch = roaster.country?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || countryMatch
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if !filteredRoasters.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedRoasters.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedRoasters.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredRoasters.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredRoasters) { roaster in
                    RoasterLibraryRow(
                        roaster: roaster,
                        isEditMode: isEditMode,
                        isSelected: selectedRoasters.contains(roaster.objectID),
                        onTap: {
                            if isEditMode {
                                toggleSelection(for: roaster)
                            } else {
                                selectedRoasterForDetail = roaster
                            }
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            roasterToDelete = roaster
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            navigationCoordinator.presentEditRoaster(roaster)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(BrewerColors.caramel)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Delete Roaster\(selectedRoasters.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedRoasters.isEmpty {
                    roasterToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedRoasters.isEmpty {
                    deleteSelectedRoasters()
                } else if let roaster = roasterToDelete {
                    deleteRoaster(roaster)
                }
            }
        } message: {
            if !selectedRoasters.isEmpty {
                Text("Are you sure you want to delete \(selectedRoasters.count) roaster\(selectedRoasters.count == 1 ? "" : "s")? This will also delete all associated recipes.")
            } else {
                Text("Are you sure you want to delete \(roasterToDelete?.name ?? "this roaster")? This will also delete all associated recipes.")
            }
        }
        .sheet(item: $selectedRoasterForDetail) { roaster in
            RoasterDetailSheet(roaster: roaster)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "building.2" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No roasters yet" : "No roasters found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            if searchText.isEmpty {
                Text("Create your first roaster to get started")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private func toggleSelection(for roaster: Roaster) {
        if selectedRoasters.contains(roaster.objectID) {
            selectedRoasters.remove(roaster.objectID)
        } else {
            selectedRoasters.insert(roaster.objectID)
        }
    }
    
    private func deleteSelectedRoasters() {
        withAnimation {
            for objectID in selectedRoasters {
                if let roaster = viewContext.object(with: objectID) as? Roaster {
                    viewContext.delete(roaster)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting roasters: \(error)")
            }
            
            selectedRoasters.removeAll()
            isEditMode = false
        }
    }
    
    private func deleteRoaster(_ roaster: Roaster) {
        withAnimation {
            viewContext.delete(roaster)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting roaster: \(error)")
            }
        }
        roasterToDelete = nil
    }
}

// MARK: - Roaster Library Row
struct RoasterLibraryRow: View {
    let roaster: Roaster
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
                
                // Roaster Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(roaster.name ?? "Untitled Roaster")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let country = roaster.country {
                            HStack(spacing: 4) {
                                if let flag = country.flag {
                                    Text(flag)
                                        .font(.system(size: 11))
                                }
                                Text(country.name ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(BrewerColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        // Show recipe count
                        if let recipes = roaster.recipes, recipes.count > 0 {
                            if roaster.country != nil {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            
                            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
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

// MARK: - Grinders Library View
struct GrindersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    )
    private var grinders: FetchedResults<Grinder>
    
    @State private var showingDeleteAlert = false
    @State private var grinderToDelete: Grinder?
    @State private var isEditMode = false
    @State private var selectedGrinders: Set<NSManagedObjectID> = []
    @State private var selectedGrinderForDetail: Grinder?
    
    private var filteredGrinders: [Grinder] {
        let allGrinders = Array(grinders)
        
        if searchText.isEmpty {
            return allGrinders
        } else {
            return allGrinders.filter { grinder in
                let nameMatch = grinder.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let typeMatch = grinder.type?.localizedCaseInsensitiveContains(searchText) ?? false
                let burrTypeMatch = grinder.burrType?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || typeMatch || burrTypeMatch
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if !filteredGrinders.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedGrinders.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedGrinders.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredGrinders.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredGrinders) { grinder in
                    GrinderLibraryRow(
                        grinder: grinder,
                        isEditMode: isEditMode,
                        isSelected: selectedGrinders.contains(grinder.objectID),
                        onTap: {
                            if isEditMode {
                                toggleSelection(for: grinder)
                            } else {
                                selectedGrinderForDetail = grinder
                            }
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            grinderToDelete = grinder
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            navigationCoordinator.presentEditGrinder(grinder)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(BrewerColors.caramel)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Delete Grinder\(selectedGrinders.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedGrinders.isEmpty {
                    grinderToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedGrinders.isEmpty {
                    deleteSelectedGrinders()
                } else if let grinder = grinderToDelete {
                    deleteGrinder(grinder)
                }
            }
        } message: {
            if !selectedGrinders.isEmpty {
                Text("Are you sure you want to delete \(selectedGrinders.count) grinder\(selectedGrinders.count == 1 ? "" : "s")? Associated recipes will keep their data but lose grinder reference.")
            } else {
                Text("Are you sure you want to delete \(grinderToDelete?.name ?? "this grinder")? Associated recipes will keep their data but lose grinder reference.")
            }
        }
        .sheet(item: $selectedGrinderForDetail) { grinder in
            GrinderDetailSheet(grinder: grinder)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "gear" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No grinders yet" : "No grinders found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            if searchText.isEmpty {
                Text("Create your first grinder to get started")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private func toggleSelection(for grinder: Grinder) {
        if selectedGrinders.contains(grinder.objectID) {
            selectedGrinders.remove(grinder.objectID)
        } else {
            selectedGrinders.insert(grinder.objectID)
        }
    }
    
    private func deleteSelectedGrinders() {
        withAnimation {
            for objectID in selectedGrinders {
                if let grinder = viewContext.object(with: objectID) as? Grinder {
                    viewContext.delete(grinder)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting grinders: \(error)")
            }
            
            selectedGrinders.removeAll()
            isEditMode = false
        }
    }
    
    private func deleteGrinder(_ grinder: Grinder) {
        withAnimation {
            viewContext.delete(grinder)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting grinder: \(error)")
            }
        }
        grinderToDelete = nil
    }
}

// MARK: - Grinder Library Row
struct GrinderLibraryRow: View {
    let grinder: Grinder
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
                
                // Grinder type icon
                Image(systemName: grinder.typeIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    .frame(width: 20, height: 20)
                
                // Grinder Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(grinder.name ?? "Untitled Grinder")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let type = grinder.type, !type.isEmpty {
                            Text(type)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if let burrType = grinder.burrType, !burrType.isEmpty {
                            if grinder.type != nil {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            
                            Text(burrType)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if grinder.burrSize > 0 {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
                            Text("\(grinder.burrSize)mm")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        // Show recipe count
                        if let recipes = grinder.recipes, recipes.count > 0 {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
                            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
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
