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
    @StateObject private var onboardingState = OnboardingStateManager.shared
    
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrewerColors.background)
        appearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: navigationCoordinator.selectedTab) {
            NavigationStack(path: $navigationCoordinator.homePath) {
                LibraryContainer(navigationCoordinator: navigationCoordinator)
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
        .onAppear {
            // Ensure tab bar appearance is maintained
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(BrewerColors.background)
            appearance.shadowColor = .clear
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .alert("Discard Recipe?", isPresented: $navigationCoordinator.showingDiscardAlert) {
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
        .fullScreenCover(isPresented: .constant(!onboardingState.hasCompletedWelcome)) {
            Welcome(
                onComplete: {
                    onboardingState.dismissOnboarding()
                    navigationCoordinator.selectedTab.wrappedValue = .add
                },
                onSkip: {
                    onboardingState.dismissOnboarding()
                    navigationCoordinator.navigateToHome()
                }
            )
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(navigationCoordinator)
            .interactiveDismissDisabled()
        }
        .overlay(alignment: .topTrailing) {
            // Debug reset button - always visible in DEBUG builds
#if DEBUG
            Button(action: {
                onboardingState.resetOnboarding()
            }) {
                Image(systemName: "arrow.clockwise")
                    .padding(8)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding()
#endif
        }
    }
    
    // MARK: - Navigation Destination Handler
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .addV60Recipe(_, _):
            AddV60Recipe(
                selectedRoaster: $navigationCoordinator.selectedRoaster,
                selectedGrinder: $navigationCoordinator.selectedGrinder,
                context: viewContext
            )
            .environmentObject(navigationCoordinator.addRecipeCoordinator)
            .environmentObject(navigationCoordinator)
            
        case .addOreaRecipe(_, _):
            AddOreaRecipe(
                selectedRoaster: $navigationCoordinator.selectedRoaster,
                selectedGrinder: $navigationCoordinator.selectedGrinder,
                context: viewContext
            )
            .environmentObject(navigationCoordinator.addRecipeCoordinator)
            .environmentObject(navigationCoordinator)
            
        case .addRoaster:
            AddRoaster(context: viewContext)
            
        case .addGrinder:
            AddGrinder(context: viewContext)
            
        case .stageChoice(let formData, let existingRecipeID):
            StageCreationChoice(formData: formData, existingRecipeID: existingRecipeID)
                .environmentObject(navigationCoordinator)
            
        case .stagesManagement(let formData, let existingRecipeID):
            GlobalBackground {
                StagesManagement(
                    formData: formData,
                    brewMath: BrewMathViewModel(grams: formData.grams, ratio: formData.ratio, water: formData.waterAmount),
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
            if recipe.brewMethodEnum == .oreaV4 {
                EditOreaRecipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                EditV60Recipe(recipe: recipe, isPresented: $navigationCoordinator.editingRecipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            
        case .brewDetail:
            Text("Brew Detail - Coming Soon")
            
        case .chartDetail(let chart):
            ChartDetailView(chart: chart)
                .environment(\.managedObjectContext, viewContext)
                
        case .settings:
            Settings()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    struct TabIcon: View {
        let imageName: String
        let label: String
        
        var body: some View {
            VStack(spacing: 4) {
                SVGIcon(imageName, size: 20)
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
