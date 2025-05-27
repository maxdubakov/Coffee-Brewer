import SwiftUI
import CoreData

// MARK: - Navigation Destinations
enum AppDestination: Hashable {
    // Add flow
    case addRecipe(roaster: Roaster?)
    case addRoaster
    case addGrinder
    case stageChoice(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    case stagesManagement(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    case recordStages(formData: RecipeFormData, existingRecipeID: NSManagedObjectID?)
    
    // Recipe flow
    case brewRecipe(recipeID: NSManagedObjectID)
    case editRecipe(recipe: Recipe)
    
    // History flow (future)
    case brewDetail(brewID: NSManagedObjectID)
}

// MARK: - Navigation Coordinator
@MainActor
class NavigationCoordinator: ObservableObject {
    // MARK: - Tab Management
    @Published var selectedTab: Main.Tab = .home
    
    // MARK: - Navigation Paths
    @Published var homePath = NavigationPath()
    @Published var addPath = NavigationPath()
    @Published var historyPath = NavigationPath()
    
    // MARK: - Modal States
    @Published var editingRecipe: Recipe?
    @Published var showingBrewCompletion = false
    @Published var brewCompletionRecipe: Recipe?
    
    // MARK: - Shared State
    @Published var selectedRoaster: Roaster?
    
    // MARK: - Existing Coordinators
    let addRecipeCoordinator = AddRecipeCoordinator()
    
    // MARK: - Tab Change Handling
    private var pendingTab: Main.Tab?
    
    init() {
        setupNotificationListeners()
    }
    
    // MARK: - Navigation Methods
    func navigateToAddRecipe(roaster: Roaster? = nil) {
        selectedRoaster = roaster
        selectedTab = .add
        if roaster != nil {
            addPath.append(AppDestination.addRecipe(roaster: roaster))
        }
    }
    
    func navigateToAddRoaster() {
        selectedTab = .add
        addPath.append(AppDestination.addRoaster)
    }
    
    func navigateToAddGrinder() {
        selectedTab = .add
        addPath.append(AppDestination.addGrinder)
    }
    
    func navigateToBrewRecipe(recipe: Recipe) {
        let recipeID = recipe.objectID
        homePath.append(AppDestination.brewRecipe(recipeID: recipeID))
    }
    
    func presentEditRecipe(_ recipe: Recipe) {
        editingRecipe = recipe
    }
    
    func dismissEditRecipe() {
        editingRecipe = nil
    }
    
    // MARK: - Navigation Stack Management
    func popToRoot(for tab: Main.Tab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .add:
            addPath = NavigationPath()
        case .history:
            historyPath = NavigationPath()
        }
    }
    
    func popToRoot() {
        homePath = NavigationPath()
        addPath = NavigationPath()
        historyPath = NavigationPath()
    }
    
    // MARK: - Tab Change Handling
    func handleTabChange(from oldTab: Main.Tab, to newTab: Main.Tab) -> Bool {
        // Check if leaving add tab with unsaved changes
        if oldTab == .add && newTab != .add {
            if addRecipeCoordinator.hasUnsavedChanges() {
                pendingTab = newTab
                return false // Will show alert, don't change tab yet
            } else {
                performTabChangeCleanup()
            }
        }
        
        selectedTab = newTab
        return true
    }
    
    func confirmTabChange() {
        guard let pendingTab = pendingTab else { return }
        performTabChangeCleanup()
        selectedTab = pendingTab
        self.pendingTab = nil
    }
    
    func cancelTabChange() {
        pendingTab = nil
    }
    
    
    private func performTabChangeCleanup() {
        selectedRoaster = nil
        popToRoot(for: .add)
        addRecipeCoordinator.resetIfNeeded()
    }
    
    // MARK: - Event Handlers
    private func setupNotificationListeners() {
        NotificationCenter.default.addObserver(
            forName: .recipeSaved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleRecipeSaved()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .roasterSaved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleRoasterSaved()
            }
        }
    }
    
    private func handleRecipeSaved() {
        addRecipeCoordinator.markRecipeAsSaved()
        popToRoot(for: .add)
        selectedRoaster = nil
        selectedTab = .home
    }
    
    private func handleRoasterSaved() {
        popToRoot(for: .add)
        selectedTab = .home
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
