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
    @Published private var _selectedTab: Main.Tab = .home
    @Published var showingDiscardAlert = false
    private var pendingTab: Main.Tab?
    
    var selectedTab: Binding<Main.Tab> {
        Binding(
            get: { self._selectedTab },
            set: { newValue in
                self.handleTabSelection(newValue)
            }
        )
    }
    
    // MARK: - Navigation Paths
    @Published var homePath = NavigationPath()
    @Published var addPath = NavigationPath()
    @Published var historyPath = NavigationPath()
    
    // MARK: - Modal States
    @Published var editingRecipe: Recipe?
    @Published var editingRoaster: Roaster?
    @Published var editingGrinder: Grinder?
    @Published var showingBrewCompletion = false
    @Published var brewCompletionRecipe: Recipe?
    
    // MARK: - Delete Recipe State
    @Published var showingDeleteAlert = false
    @Published var recipeToDelete: Recipe?
    
    // MARK: - Shared State
    @Published var selectedRoaster: Roaster?
    
    // MARK: - Existing Coordinators
    let addRecipeCoordinator = AddRecipeCoordinator()
    
    init() {
        setupNotificationListeners()
    }
    
    // MARK: - Navigation Methods
    func navigateToAddRecipe(roaster: Roaster? = nil) {
        selectedRoaster = roaster
        _selectedTab = .add
        if roaster != nil {
            addPath.append(AppDestination.addRecipe(roaster: roaster))
        }
    }
    
    func navigateToAddRoaster() {
        _selectedTab = .add
        addPath.append(AppDestination.addRoaster)
    }
    
    func navigateToAddGrinder() {
        _selectedTab = .add
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
    
    func presentEditRoaster(_ roaster: Roaster) {
        editingRoaster = roaster
    }
    
    func dismissEditRoaster() {
        editingRoaster = nil
    }
    
    func presentEditGrinder(_ grinder: Grinder) {
        editingGrinder = grinder
    }
    
    func dismissEditGrinder() {
        editingGrinder = nil
    }
    
    // MARK: - Recipe Deletion
    func confirmDeleteRecipe(_ recipe: Recipe) {
        recipeToDelete = recipe
        showingDeleteAlert = true
    }
    
    func deleteRecipe(in context: NSManagedObjectContext) {
        guard let recipe = recipeToDelete else { return }
        
        withAnimation(.bouncy(duration: 0.5)) {
            context.delete(recipe)
            
            do {
                try context.save()
                // Send notification for any views that need to update
                NotificationCenter.default.post(name: .recipeDeleted, object: nil)
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
        
        recipeToDelete = nil
        showingDeleteAlert = false
    }
    
    func cancelDeleteRecipe() {
        recipeToDelete = nil
        showingDeleteAlert = false
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
    private func handleTabSelection(_ newTab: Main.Tab) {
        let currentTab = _selectedTab
        
        // Check if we should block the change
        if currentTab == .add && newTab != .add {
            if addRecipeCoordinator.hasUnsavedChanges() {
                pendingTab = newTab
                showingDiscardAlert = true
                return // Don't change tab
            }
        }
        
        // Allow the change
        performTabChange(to: newTab)
    }
    
    private func performTabChange(to tab: Main.Tab) {
        if _selectedTab == .add && tab != .add {
            performTabChangeCleanup()
        }
        _selectedTab = tab
    }
    
    func confirmTabChange() {
        guard let pendingTab = pendingTab else { return }
        performTabChange(to: pendingTab)
        self.pendingTab = nil
        showingDiscardAlert = false
    }
    
    func cancelTabChange() {
        pendingTab = nil
        showingDiscardAlert = false
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
        
        NotificationCenter.default.addObserver(
            forName: .grinderSaved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleGrinderSaved()
            }
        }
    }
    
    private func handleRecipeSaved() {
        addRecipeCoordinator.markRecipeAsSaved()
        popToRoot(for: .add)
        selectedRoaster = nil
        _selectedTab = .home
    }
    
    private func handleRoasterSaved() {
        popToRoot(for: .add)
        _selectedTab = .home
    }
    
    private func handleGrinderSaved() {
        popToRoot(for: .add)
        _selectedTab = .home
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    static let recipeDeleted = Notification.Name("recipeDeleted")
}
