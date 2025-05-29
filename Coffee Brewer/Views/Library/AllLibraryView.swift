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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                                        isEditMode: false,
                                        isSelected: false,
                                        onTap: {
                                            navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
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
                                        isEditMode: false,
                                        isSelected: false,
                                        onTap: {
                                            selectedRoasterForDetail = roaster
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
                                        isEditMode: false,
                                        isSelected: false,
                                        onTap: {
                                            selectedGrinderForDetail = grinder
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
