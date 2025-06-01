import SwiftUI
import CoreData

// MARK: - Notification Extension
extension Notification.Name {
    static let navigateToRecipe = Notification.Name("navigateToRecipe")
}

struct Recipes: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    // MARK: - State
    @State private var showLibraryOverlay = false
    @State private var searchText = ""
    @State private var selectedLibraryTab: LibraryTab = .all
    @Namespace private var searchBarNamespace
    
    // MARK: - Fetch Requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
        animation: .default
    )
    private var allRecipes: FetchedResults<Recipe>
    
    // MARK: - Computed Properties
    private var featuredRecipe: Recipe? {
        allRecipes.first { $0.lastBrewedAt != nil }
    }
    
    private var quickBrewRecipes: [Recipe] {
        let recentRecipes = allRecipes
            .filter { $0.lastBrewedAt != nil }
            .prefix(10)
        
        return Array(recentRecipes)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Fixed header
                VStack(spacing: 16) {
                    PageTitleH1("Recipes", subtitle: "Discover your perfect brew")
                    
                    // Fake search bar that opens library overlay
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showLibraryOverlay = true
                        }
                    }) {
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(BrewerColors.textSecondary)
                                    .font(.system(size: 14))
                                
                                Text("Search library...")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(BrewerColors.placeholder)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(BrewerColors.cardBackground.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        BrewerColors.caramel.opacity(0.1),
                                                        BrewerColors.caramel.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 24)
                .background(BrewerColors.background)
                
                // Scrollable content
                if allRecipes.count == 0 {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            quickBrewSection
                            
                            RoasterGroupedView(navigationCoordinator: navigationCoordinator)
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)
                    
                }            }
            .scaleEffect(showLibraryOverlay ? 0.92 : 1)
            .opacity(showLibraryOverlay ? 0.4 : 1)
            .blur(radius: showLibraryOverlay ? 2 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showLibraryOverlay)
            
            // Library overlay
            if showLibraryOverlay {
                LibraryOverlay(
                    isPresented: $showLibraryOverlay,
                    searchText: $searchText,
                    selectedTab: $selectedLibraryTab,
                    navigationCoordinator: navigationCoordinator
                )
            }
        }
        .sheet(item: $navigationCoordinator.editingRecipe) { recipe in
            NavigationStack {
                EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .tint(BrewerColors.cream)
            .interactiveDismissDisabled()
        }
        .alert("Delete Recipe", isPresented: $navigationCoordinator.showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                navigationCoordinator.cancelDeleteRecipe()
            }
            
            Button("Delete", role: .destructive) {
                navigationCoordinator.deleteRecipe(in: viewContext)
            }
        } message: {
            Text("Are you sure you want to delete \(navigationCoordinator.recipeToDelete?.name ?? "this recipe")?")
        }
    }
    
    private var emptyStateView: some View {
        CenteredContent(verticalOffset: -70) {
            VStack(spacing: 16) {
                SVGIcon("coffee.beans", size: 70, color: BrewerColors.caramel)
                
                Text("No recipes yet")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Your recipes will appear here")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var quickBrewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Brew")
                .font(.headline)
                .foregroundColor(BrewerColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickBrewRecipes) { recipe in
                        RecipeCard(
                            recipe: recipe,
                            onBrewTapped: {
                                navigationCoordinator.navigateToBrewRecipe(recipe: recipe)
                            },
                            onEditTapped: {
                                navigationCoordinator.presentEditRecipe(recipe)
                            },
                            onDeleteTapped: {
                                navigationCoordinator.confirmDeleteRecipe(recipe)
                            },
                            onDuplicateTapped: {
                                navigationCoordinator.duplicateRecipe(recipe, in: viewContext)
                            }
                        )
                        .frame(width: 180)
                    }
                }
            }
        }
    }
    
}

// MARK: - Library Overlay
struct LibraryOverlay: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @Binding var selectedTab: LibraryTab
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // Background that dismisses overlay
            Color.black
                .opacity(isPresented ? 0.5 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: isPresented)
                .onTapGesture {
                    // Dismiss keyboard immediately
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                // Search header
                VStack(spacing: 16) {
                    HStack {
                        SearchBar(searchText: $searchText, placeholder: searchPlaceholder)
                            .focused($isSearchFocused)
                        
                        Button("Cancel") {
                            // Dismiss keyboard immediately
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                isPresented = false
                            }
                        }
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.caramel)
                        .opacity(isPresented ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25).delay(isPresented ? 0.15 : 0), value: isPresented)
                    }
                    
                    LibraryTabButton(selectedTab: $selectedTab)
                        .opacity(isPresented ? 1 : 0)
                        .offset(y: isPresented ? 0 : 20)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(isPresented ? 0.1 : 0), value: isPresented)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(BrewerColors.background)
                
                Divider()
                    .padding(.bottom, 12)
                    .opacity(isPresented ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2).delay(isPresented ? 0.2 : 0), value: isPresented)
                
                // Library content
                LibraryContent(
                    selectedTab: selectedTab,
                    navigationCoordinator: navigationCoordinator,
                    searchText: searchText
                )
                .background(BrewerColors.background)
                .opacity(isPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.3).delay(isPresented ? 0.25 : 0), value: isPresented)
                .onChange(of: navigationCoordinator.homePath) {
                    // Close overlay when navigation happens
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        isPresented = false
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .background(BrewerColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.top, 60)
            .offset(y: isPresented ? 0 : 40)
            .animation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0), value: isPresented)
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
    }
    
    private var searchPlaceholder: String {
        switch selectedTab {
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

#Preview {
    GlobalBackground {
        Recipes(navigationCoordinator: NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
