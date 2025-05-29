import SwiftUI
import CoreData

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    @State private var showLibraryMode = false
    @State private var selectedLibraryTab: LibraryTab = .recipes
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
    }
    
    private var searchPlaceholder: String {
        switch selectedLibraryTab {
        case .recipes:
            return "Search recipes..."
        case .roasters:
            return "Search roasters..."
        case .grinders:
            return "Search grinders..."
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
            case .recipes:
                RecipesLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .roasters:
                RoastersLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                    .padding(.horizontal, 20)
            case .grinders:
                ScrollView {
                    GrindersLibraryView(navigationCoordinator: navigationCoordinator)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    Spacer().frame(height: 100)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
