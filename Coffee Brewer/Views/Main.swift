import SwiftUI

struct Main: View {
    // MARK: - Nested Types
    enum Tab {
        case home, add, history
    }
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Navigation
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @State private var showingDiscardAlert = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrewerColors.background)
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            NavigationStack(path: $navigationCoordinator.homePath) {
                Recipes(navigationCoordinator: navigationCoordinator)
                    .background(BrewerColors.background)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                TabIcon(imageName: "home", label: "Home")
            }
            .tag(Tab.home)

            NavigationStack(path: $navigationCoordinator.addPath) {
                AddChoice(navigationCoordinator: navigationCoordinator)
                    .background(BrewerColors.background)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                TabIcon(imageName: "add.recipe", label: "Add")
            }
            .tag(Tab.add)

            NavigationStack(path: $navigationCoordinator.historyPath) {
                History()
                    .background(BrewerColors.background)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                TabIcon(imageName: "history", label: "History")
            }
            .tag(Tab.history)
        }
        .accentColor(BrewerColors.cream)
        .onChange(of: navigationCoordinator.selectedTab) { oldTab, newTab in
            let shouldChange = navigationCoordinator.handleTabChange(from: oldTab, to: newTab)
            if !shouldChange {
                showingDiscardAlert = true
            }
        }
        .alert("Discard Recipe?", isPresented: $showingDiscardAlert) {
            Button("Cancel", role: .cancel) {
                navigationCoordinator.cancelTabChange()
            }
            Button("Discard", role: .destructive) {
                navigationCoordinator.confirmTabChange()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to leave?")
        }
        .environmentObject(navigationCoordinator)
    }
    
    // MARK: - Navigation Destination Handler
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .addRecipe(_):
            AddRecipe(
                selectedTab: $navigationCoordinator.selectedTab,
                selectedRoaster: $navigationCoordinator.selectedRoaster,
                context: viewContext
            )
            .environmentObject(navigationCoordinator.addRecipeCoordinator)
            .environmentObject(navigationCoordinator)
            
        case .addRoaster:
            AddRoaster(selectedTab: $navigationCoordinator.selectedTab, context: viewContext)
            
        case .addGrinder:
            GlobalBackground {
                Text("Add Grinder - Coming Soon")
                    .foregroundColor(BrewerColors.textSecondary)
            }
            
        case .stageChoice(let formData, let existingRecipeID):
            StageCreationChoice(formData: formData, existingRecipeID: existingRecipeID)
                .environmentObject(navigationCoordinator)
            
        case .stagesManagement(let formData, let existingRecipeID):
            GlobalBackground {
                StagesManagement(
                    formData: formData,
                    brewMath: BrewMathViewModel(grams: formData.grams, ratio: formData.ratio, water: formData.waterAmount),
                    selectedTab: $navigationCoordinator.selectedTab,
                    context: viewContext,
                    existingRecipeID: existingRecipeID,
                    onFormDataUpdate: { _ in }
                )
            }
            
        case .recordStages(let formData, let existingRecipeID):
            GlobalBackground {
                RecordStages(
                    formData: formData,
                    brewMath: BrewMathViewModel(grams: formData.grams, ratio: formData.ratio, water: formData.waterAmount),
                    selectedTab: $navigationCoordinator.selectedTab,
                    context: viewContext,
                    existingRecipeID: existingRecipeID
                )
            }
            
        case .brewRecipe(let recipeID):
            if let recipe = try? viewContext.existingObject(with: recipeID) as? Recipe {
                BrewRecipe(recipe: recipe)
            } else {
                Text("Recipe not found")
            }
            
        case .editRecipe(let recipe):
            EditRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                .environment(\.managedObjectContext, viewContext)
            
        case .brewDetail:
            Text("Brew Detail - Coming Soon")
        }
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
        Main()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
