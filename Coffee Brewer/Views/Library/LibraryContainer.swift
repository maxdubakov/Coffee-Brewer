import SwiftUI
import CoreData

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    @State private var showLibraryMode = false
    @State private var selectedLibraryTab: LibraryTab = .all
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Unified Navigation Header
            VStack(spacing: 20) {
                LibraryHeader(
                    selectedTab: $selectedLibraryTab,
                    showLibraryMode: $showLibraryMode
                )
                // Search Bar (only visible in library mode)
                if showLibraryMode {
                    VStack(spacing: 10) {
                        SearchBar(searchText: $searchText, placeholder: searchPlaceholder)
                            .padding(.horizontal, 20)
                        LibraryTabButton(selectedTab: $selectedLibraryTab)
                    }
                }
            }
            
            // Main Content
            Group {
                if showLibraryMode {
                    LibraryContent(
                        selectedTab: selectedLibraryTab,
                        navigationCoordinator: navigationCoordinator,
                        searchText: searchText
                    )
                } else {
                    Recipes(navigationCoordinator: navigationCoordinator)
                }
            }
        }
        .padding(.top, 20)
        .animation(.easeInOut(duration: 0.3), value: showLibraryMode)
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, navigationCoordinator.editingRecipe?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
        .sheet(item: $navigationCoordinator.editingRoaster) { roaster in
            NavigationStack {
                EditRoaster(roaster: roaster, isPresented: $navigationCoordinator.editingRoaster)
                    .environment(\.managedObjectContext, navigationCoordinator.editingRoaster?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
        .sheet(item: $navigationCoordinator.editingGrinder) { grinder in
            NavigationStack {
                EditGrinder(grinder: grinder, isPresented: $navigationCoordinator.editingGrinder)
                    .environment(\.managedObjectContext, navigationCoordinator.editingGrinder?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
    }
    
    private var searchPlaceholder: String {
        switch selectedLibraryTab {
        case .all:
            return "Search everything..."
        case .recipes:
            return "Search recipes..."
        case .roasters:
            return "Search roasters..."
        case .grinders:
            return "Search grinders..."
        case .brews:
            return "Search brews..."
        }
    }
}


// MARK: - Library Content View
struct LibraryContent: View {
    let selectedTab: LibraryTab
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    var body: some View {
        Group {
            switch selectedTab {
            case .all:
                AllLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .recipes:
                RecipesLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .roasters:
                RoastersLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .grinders:
                GrindersLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .brews:
                BrewsLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            }
        }
    }
}
