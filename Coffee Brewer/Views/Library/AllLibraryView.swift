import SwiftUI
import CoreData

// MARK: - All Library View
struct AllLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)],
        animation: .default
    )
    private var recipes: FetchedResults<Recipe>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )
    private var roasters: FetchedResults<Roaster>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    )
    private var grinders: FetchedResults<Grinder>
    
    @State private var selectedRoasterForDetail: Roaster?
    @State private var selectedGrinderForDetail: Grinder?
    
    // MARK: - Edit Mode State
    @State private var isEditMode = false
    @State private var selectedRecipes: Set<NSManagedObjectID> = []
    @State private var selectedRoasters: Set<NSManagedObjectID> = []
    @State private var selectedGrinders: Set<NSManagedObjectID> = []
    @State private var showingMultiDeleteAlert = false
    
    private var filteredRecipes: [Recipe] {
        let allRecipes = Array(recipes)
        if searchText.isEmpty {
            return allRecipes
        } else {
            return allRecipes.filter { recipe in
                let nameMatch = recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let roasterMatch = recipe.roaster?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let grinderMatch = recipe.grinder?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || roasterMatch || grinderMatch
            }
        }
    }
    
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
    
    private var hasAnyItems: Bool {
        !filteredRecipes.isEmpty || !filteredRoasters.isEmpty || !filteredGrinders.isEmpty
    }
    
    private var totalSelectedItems: Int {
        selectedRecipes.count + selectedRoasters.count + selectedGrinders.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if hasAnyItems {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedRecipes.removeAll()
                                selectedRoasters.removeAll()
                                selectedGrinders.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && totalSelectedItems > 0 {
                        Button("Delete") {
                            showingMultiDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if !hasAnyItems {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // Recipes Section
                    if !filteredRecipes.isEmpty {
                        Section {
                            ForEach(Array(filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                                VStack(spacing: 0) {
                                    RecipeLibraryRow(
                                        recipe: recipe,
                                        isEditMode: isEditMode,
                                        isSelected: selectedRecipes.contains(recipe.objectID),
                                        onTap: {
                                            if isEditMode {
                                                toggleRecipeSelection(for: recipe)
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
                                        navigationCoordinator.confirmDeleteRecipe(recipe)
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
                        } header: {
                            SectionHeaderView(title: "Recipes", count: filteredRecipes.count)
                        }
                    }
                    
                    // Roasters Section
                    if !filteredRoasters.isEmpty {
                        Section {
                            ForEach(Array(filteredRoasters.enumerated()), id: \.element.id) { index, roaster in
                                VStack(spacing: 0) {
                                    RoasterLibraryRow(
                                        roaster: roaster,
                                        isEditMode: isEditMode,
                                        isSelected: selectedRoasters.contains(roaster.objectID),
                                        onTap: {
                                            if isEditMode {
                                                toggleRoasterSelection(for: roaster)
                                            } else {
                                                selectedRoasterForDetail = roaster
                                            }
                                        }
                                    )
                                    
                                    if index < filteredRoasters.count - 1 {
                                        CustomDivider()
                                            .padding(.leading, 32)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        navigationCoordinator.confirmDeleteRoaster(roaster)
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
                        } header: {
                            SectionHeaderView(title: "Roasters", count: filteredRoasters.count)
                        }
                    }
                    
                    // Grinders Section
                    if !filteredGrinders.isEmpty {
                        Section {
                            ForEach(Array(filteredGrinders.enumerated()), id: \.element.id) { index, grinder in
                                VStack(spacing: 0) {
                                    GrinderLibraryRow(
                                        grinder: grinder,
                                        isEditMode: isEditMode,
                                        isSelected: selectedGrinders.contains(grinder.objectID),
                                        onTap: {
                                            if isEditMode {
                                                toggleGrinderSelection(for: grinder)
                                            } else {
                                                selectedGrinderForDetail = grinder
                                            }
                                        }
                                    )
                                    
                                    if index < filteredGrinders.count - 1 {
                                        CustomDivider()
                                            .padding(.leading, 44)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        navigationCoordinator.confirmDeleteGrinder(grinder)
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
                        } header: {
                            SectionHeaderView(title: "Grinders", count: filteredGrinders.count)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $selectedRoasterForDetail) { roaster in
            RoasterDetailSheet(roaster: roaster)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedGrinderForDetail) { grinder in
            GrinderDetailSheet(grinder: grinder)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Delete Items?", isPresented: $showingMultiDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(totalSelectedItems) selected item\(totalSelectedItems == 1 ? "" : "s")? This action cannot be undone.")
        }
        .alert("Delete Recipe?", isPresented: $navigationCoordinator.showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                navigationCoordinator.deleteRecipe(in: viewContext)
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Delete Roaster?", isPresented: $navigationCoordinator.showingDeleteRoasterAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                navigationCoordinator.deleteRoaster(in: viewContext)
            }
        } message: {
            Text("This will also delete all associated recipes. This action cannot be undone.")
        }
        .alert("Delete Grinder?", isPresented: $navigationCoordinator.showingDeleteGrinderAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                navigationCoordinator.deleteGrinder(in: viewContext)
            }
        } message: {
            Text("Associated recipes will keep their data but lose grinder reference.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "square.stack.3d.up" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No items yet" : "No items found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            if searchText.isEmpty {
                Text("Create recipes, roasters, and grinders to get started")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Selection Methods
    private func toggleRecipeSelection(for recipe: Recipe) {
        if selectedRecipes.contains(recipe.objectID) {
            selectedRecipes.remove(recipe.objectID)
        } else {
            selectedRecipes.insert(recipe.objectID)
        }
    }
    
    private func toggleRoasterSelection(for roaster: Roaster) {
        if selectedRoasters.contains(roaster.objectID) {
            selectedRoasters.remove(roaster.objectID)
        } else {
            selectedRoasters.insert(roaster.objectID)
        }
    }
    
    private func toggleGrinderSelection(for grinder: Grinder) {
        if selectedGrinders.contains(grinder.objectID) {
            selectedGrinders.remove(grinder.objectID)
        } else {
            selectedGrinders.insert(grinder.objectID)
        }
    }
    
    // MARK: - Multi-Delete Methods
    private func deleteSelectedItems() {
        withAnimation {
            // Delete recipes
            for objectID in selectedRecipes {
                if let recipe = viewContext.object(with: objectID) as? Recipe {
                    viewContext.delete(recipe)
                }
            }
            
            // Delete roasters
            for objectID in selectedRoasters {
                if let roaster = viewContext.object(with: objectID) as? Roaster {
                    viewContext.delete(roaster)
                }
            }
            
            // Delete grinders
            for objectID in selectedGrinders {
                if let grinder = viewContext.object(with: objectID) as? Grinder {
                    viewContext.delete(grinder)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting items: \(error)")
            }
            
            selectedRecipes.removeAll()
            selectedRoasters.removeAll()
            selectedGrinders.removeAll()
            isEditMode = false
        }
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(BrewerColors.caramel)
        }
        .padding(.vertical, 8)
        .background(BrewerColors.background)
        .listRowInsets(EdgeInsets())
    }
}
