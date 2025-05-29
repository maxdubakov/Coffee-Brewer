import SwiftUI

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    @State private var showLibraryMode = false
    @State private var selectedLibraryTab: LibraryTab = .recipes
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            if showLibraryMode {
                LibraryNavigationHeader(
                    selectedTab: $selectedLibraryTab,
                    showLibraryMode: $showLibraryMode
                )
            } else {
                LibraryAccessButton(showLibraryMode: $showLibraryMode)
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

// MARK: - Library Access Button
struct LibraryAccessButton: View {
    @Binding var showLibraryMode: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showLibraryMode = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BrewerColors.caramel)
                    
                    Text("Library")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        BrewerColors.cardBackground.opacity(0.9),
                                        BrewerColors.cardBackground.opacity(0.8)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        BrewerColors.caramel.opacity(0.3),
                                        BrewerColors.caramel.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.top, 8)
            .padding(.trailing, 20)
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
