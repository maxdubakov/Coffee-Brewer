import SwiftUI

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    @State private var showLibraryMode = false
    @State private var selectedLibraryTab: LibraryTab = .recipes
    
    var body: some View {
        VStack(spacing: 0) {
            // Unified Navigation Header
            VStack(spacing: 0) {
                LibraryHeader(
                    selectedTab: $selectedLibraryTab,
                    showLibraryMode: $showLibraryMode
                )
                .padding(.bottom, 20)
                
                // Tab Pills (only visible in library mode)
                if showLibraryMode {
                    LibraryTabButton(selectedTab: $selectedLibraryTab)
                }
            }
            
            // Main Content
            Group {
                if showLibraryMode {
                    LibraryContent(
                        selectedTab: selectedLibraryTab,
                        navigationCoordinator: navigationCoordinator
                    )
                } else {
                    Recipes(navigationCoordinator: navigationCoordinator)
                }
            }
        }
    }
}


// MARK: - Library Content View
struct LibraryContent: View {
    let selectedTab: LibraryTab
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Group {
                    switch selectedTab {
                    case .recipes:
                        RecipesLibraryView(navigationCoordinator: navigationCoordinator)
                    case .roasters:
                        RoastersLibraryView(navigationCoordinator: navigationCoordinator)
                    case .grinders:
                        GrindersLibraryView(navigationCoordinator: navigationCoordinator)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer().frame(height: 100)
            }
        }
        .scrollIndicators(.hidden)
    }
}
