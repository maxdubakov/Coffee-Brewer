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
    
    // History flow
    case brewDetail(brewID: NSManagedObjectID)
    case chartDetail(chart: Chart)
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
    
    // MARK: - Delete Roaster State
    @Published var showingDeleteRoasterAlert = false
    @Published var roasterToDelete: Roaster?
    
    // MARK: - Delete Grinder State
    @Published var showingDeleteGrinderAlert = false
    @Published var grinderToDelete: Grinder?
    
    // MARK: - Delete Brew State
    @Published var showingDeleteBrewAlert = false
    @Published var brewToDelete: Brew?
    
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
        addPath.append(AppDestination.addRecipe(roaster: roaster))
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
    
    func navigateToChartDetail(chart: Chart) {
        historyPath.append(AppDestination.chartDetail(chart: chart))
    }
    
    func navigateToLibraryBrews() {
        _selectedTab = .home
        // This will be used to trigger library navigation with brews tab
        NotificationCenter.default.post(name: .navigateToLibraryBrews, object: nil)
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
    
    // MARK: - Recipe Duplication
    func duplicateRecipe(_ recipe: Recipe, in context: NSManagedObjectContext) {
        withAnimation {
            do {
                // Create new recipe with copied properties
                let newRecipe = Recipe(context: context)
                newRecipe.id = UUID()
                newRecipe.name = (recipe.name ?? "Recipe") + " (Copy)"
                newRecipe.roaster = recipe.roaster
                newRecipe.grinder = recipe.grinder
                newRecipe.temperature = recipe.temperature
                newRecipe.grindSize = recipe.grindSize
                newRecipe.grams = recipe.grams
                newRecipe.ratio = recipe.ratio
                newRecipe.waterAmount = recipe.waterAmount
                newRecipe.lastBrewedAt = Date()
                
                // Duplicate stages
                for stage in recipe.stagesArray {
                    let newStage = Stage(context: context)
                    newStage.id = UUID()
                    newStage.type = stage.type
                    newStage.seconds = stage.seconds
                    newStage.waterAmount = stage.waterAmount
                    newStage.orderIndex = stage.orderIndex
                    newStage.recipe = newRecipe
                }
                
                try context.save()
                
                // Send notification for any views that need to update
                NotificationCenter.default.post(name: .recipeDuplicated, object: nil, userInfo: ["recipe": newRecipe])
                
                // Provide haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            } catch {
                print("Error duplicating recipe: \(error)")
            }
        }
    }
    
    // MARK: - Roaster Deletion
    func confirmDeleteRoaster(_ roaster: Roaster) {
        roasterToDelete = roaster
        showingDeleteRoasterAlert = true
    }
    
    func deleteRoaster(in context: NSManagedObjectContext) {
        guard let roaster = roasterToDelete else { return }
        
        withAnimation(.bouncy(duration: 0.5)) {
            context.delete(roaster)
            
            do {
                try context.save()
            } catch {
                print("Error deleting roaster: \(error)")
            }
        }
        
        roasterToDelete = nil
        showingDeleteRoasterAlert = false
    }
    
    func cancelDeleteRoaster() {
        roasterToDelete = nil
        showingDeleteRoasterAlert = false
    }
    
    // MARK: - Grinder Deletion
    func confirmDeleteGrinder(_ grinder: Grinder) {
        grinderToDelete = grinder
        showingDeleteGrinderAlert = true
    }
    
    func deleteGrinder(in context: NSManagedObjectContext) {
        guard let grinder = grinderToDelete else { return }
        
        withAnimation(.bouncy(duration: 0.5)) {
            context.delete(grinder)
            
            do {
                try context.save()
            } catch {
                print("Error deleting grinder: \(error)")
            }
        }
        
        grinderToDelete = nil
        showingDeleteGrinderAlert = false
    }
    
    func cancelDeleteGrinder() {
        grinderToDelete = nil
        showingDeleteGrinderAlert = false
    }
    
    // MARK: - Brew Deletion
    func confirmDeleteBrew(_ brew: Brew) {
        brewToDelete = brew
        showingDeleteBrewAlert = true
    }
    
    func deleteBrew(in context: NSManagedObjectContext) {
        guard let brew = brewToDelete else { return }
        
        withAnimation(.bouncy(duration: 0.5)) {
            context.delete(brew)
            
            do {
                try context.save()
            } catch {
                print("Error deleting brew: \(error)")
            }
        }
        
        brewToDelete = nil
        showingDeleteBrewAlert = false
    }
    
    func cancelDeleteBrew() {
        brewToDelete = nil
        showingDeleteBrewAlert = false
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
    static let recipeDuplicated = Notification.Name("recipeDuplicated")
    static let navigateToLibraryBrews = Notification.Name("navigateToLibraryBrews")
}
