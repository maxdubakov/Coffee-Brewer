import SwiftUI

struct MainView: View {
    // MARK: - Nested Types
    enum Tab {
        case home, add, history
    }
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - State
    @State private var selectedTab: Tab = .home
    @State private var selectedRoaster: Roaster? = nil
    @State private var pendingTab: Tab? = nil
    @State private var showingDiscardAlert = false
    @State private var isHandlingTabChange = false
    @StateObject private var addRecipeCoordinator = AddRecipeCoordinator()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrewerColors.background)
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                Recipes(selectedTab: $selectedTab, selectedRoaster: $selectedRoaster)
                    .background(BrewerColors.background)
            }
            .tabItem {
                TabIcon(imageName: "home", label: "Home")
            }
            .tag(Tab.home)

            AddRecipeCoordinatorView(
                coordinator: addRecipeCoordinator,
                selectedRoaster: $selectedRoaster,
                context: viewContext,
                selectedTab: $selectedTab
            )
            .background(BrewerColors.background)
            .tabItem {
                TabIcon(imageName: "add.recipe", label: "Add")
            }
            .tag(Tab.add)

            History()
                .background(BrewerColors.background)
                .tabItem {
                    TabIcon(imageName: "history", label: "History")
                }
                .tag(Tab.history)
        }
        .accentColor(BrewerColors.cream)
        .onChange(of: selectedTab) { oldTab, newTab in
            handleTabChange(from: oldTab, to: newTab)
        }
        .onReceive(NotificationCenter.default.publisher(for: .recipeSaved)) { _ in
            handleRecipeSaved()
        }
        .alert("Discard Recipe?", isPresented: $showingDiscardAlert) {
            Button("Cancel", role: .cancel) {
                selectedTab = .add
                pendingTab = nil
            }
            Button("Discard", role: .destructive) {
                if let pendingTab = pendingTab {
                    selectedTab = pendingTab
                    performTabChangeCleanup()
                }
                pendingTab = nil
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to leave?")
        }
    }
    
    private func performTabChangeCleanup() {
        selectedRoaster = nil
        // This will call resetAndDiscardChanges() which WILL delete the recipe
        addRecipeCoordinator.resetIfNeeded()
    }
    
    // MARK: - Tab Change Handler
    private func handleTabChange(from oldTab: Tab, to newTab: Tab) {
        // Prevent recursive handling
        guard !isHandlingTabChange else { return }
        
        // Check if leaving add tab with unsaved changes
        if oldTab == .add && newTab != .add {
            if addRecipeCoordinator.hasUnsavedChanges() {
                isHandlingTabChange = true
                // Store where the user wants to go
                pendingTab = newTab
                // Revert the tab selection (will be changed if user confirms)
                selectedTab = .add
                // Show the alert
                showingDiscardAlert = true
                isHandlingTabChange = false
            } else {
                // No unsaved changes, proceed with immediate cleanup
                performTabChangeCleanup()
            }
        } else if oldTab != .add && newTab == .add && selectedRoaster == nil && !showingDiscardAlert {
            // Entering Add tab without a recipe or roaster selected - ensure clean state
            // Don't reset if we're showing the discard alert
            addRecipeCoordinator.resetIfNeeded()
        }
    }
    
    private func handleRecipeSaved() {
        // Mark recipe as saved in coordinator
        addRecipeCoordinator.markRecipeAsSaved()
        
        // Clear selected states
        selectedRoaster = nil
        
        // Navigate to home tab
        selectedTab = .home
    }

    struct TabIcon: View {
        let imageName: String
        let label: String

        var body: some View {
            VStack(spacing: 4) {
                Image(imageName)
                    .renderingMode(.template)
                Text(label)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    GlobalBackground {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
