import SwiftUI
import CoreData

// MARK: - Brew Editor Route
enum BrewEditorRoute: Hashable {
    case template(BrewMethod)
    case cloneFromBrew(NSManagedObjectID)
}

// MARK: - Navigation Destinations
enum AppDestination: Hashable {
    // Add flow
    case addCoffee
    case addRoaster
    case addGrinder

    // History flow
    case brewDetail(brewID: NSManagedObjectID)
    case chartDetail(chart: Chart)

    // Settings flow
    case settings
}

// MARK: - Navigation Coordinator
@MainActor
class NavigationCoordinator: ObservableObject {
    // MARK: - Tab Management
    @Published private var _selectedTab: Main.Tab = .brew

    var selectedTab: Binding<Main.Tab> {
        Binding(
            get: { self._selectedTab },
            set: { newValue in
                self._selectedTab = newValue
            }
        )
    }

    // MARK: - Navigation Paths
    @Published var addPath = NavigationPath()
    @Published var historyPath = NavigationPath()
    @Published var brewPath = NavigationPath()

    // MARK: - Modal States
    @Published var editingCoffee: Coffee?
    @Published var editingRoaster: Roaster?
    @Published var editingGrinder: Grinder?

    // MARK: - Delete Coffee State
    @Published var showingDeleteCoffeeAlert = false
    @Published var coffeeToDelete: Coffee?

    // MARK: - Delete Roaster State
    @Published var showingDeleteRoasterAlert = false
    @Published var roasterToDelete: Roaster?

    // MARK: - Delete Grinder State
    @Published var showingDeleteGrinderAlert = false
    @Published var grinderToDelete: Grinder?

    // MARK: - Delete Brew State
    @Published var showingDeleteBrewAlert = false
    @Published var brewToDelete: Brew?

    // MARK: - Pending Clone State
    @Published var pendingCloneBrew: Brew?

    // MARK: - Rating Sheet State
    /// Non-nil when the deep-link rating sheet should be presented.
    @Published var brewToRate: Brew?

    init() {
        setupNotificationListeners()
    }

    // MARK: - Navigation Methods
    func navigateToAddCoffee() {
        _selectedTab = .add
        addPath.append(AppDestination.addCoffee)
    }

    func navigateToAddRoaster() {
        _selectedTab = .add
        addPath.append(AppDestination.addRoaster)
    }

    func navigateToAddGrinder() {
        _selectedTab = .add
        addPath.append(AppDestination.addGrinder)
    }

    func navigateToChartDetail(chart: Chart) {
        historyPath.append(AppDestination.chartDetail(chart: chart))
    }

    func navigateToHistory() {
        _selectedTab = .history
    }

    func navigateToSettings() {
        brewPath.append(AppDestination.settings)
    }

    func startBrewFromClone(brew: Brew) {
        brewPath = NavigationPath()
        _selectedTab = .brew
        brewPath.append(BrewEditorRoute.cloneFromBrew(brew.objectID))
    }

    /// Called from sheet `onDismiss` to process a pending "Brew Again" action.
    func processPendingClone() {
        guard let brew = pendingCloneBrew else { return }
        pendingCloneBrew = nil
        startBrewFromClone(brew: brew)
    }

    /// Fetches the brew by UUID and sets `brewToRate` to present the rating sheet.
    func openRatingSheet(brewID: UUID) {
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<Brew>(entityName: "Brew")
        request.predicate = NSPredicate(format: "id == %@", brewID as CVarArg)
        request.fetchLimit = 1
        if let brew = (try? context.fetch(request))?.first {
            brewToRate = brew
        }
    }

    func presentEditCoffee(_ coffee: Coffee) {
        editingCoffee = coffee
    }

    func dismissEditCoffee() {
        editingCoffee = nil
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

    // MARK: - Coffee Deletion
    func confirmDeleteCoffee(_ coffee: Coffee) {
        coffeeToDelete = coffee
        showingDeleteCoffeeAlert = true
    }

    func deleteCoffee(in context: NSManagedObjectContext) {
        guard let coffee = coffeeToDelete else { return }

        withAnimation(.bouncy(duration: 0.5)) {
            context.delete(coffee)

            do {
                try context.save()
            } catch {
                print("Error deleting coffee: \(error)")
            }
        }

        coffeeToDelete = nil
        showingDeleteCoffeeAlert = false
    }

    func cancelDeleteCoffee() {
        coffeeToDelete = nil
        showingDeleteCoffeeAlert = false
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
        case .brew:
            brewPath = NavigationPath()
        case .add:
            addPath = NavigationPath()
        case .history:
            historyPath = NavigationPath()
        }
    }

    func popToRoot() {
        brewPath = NavigationPath()
        addPath = NavigationPath()
        historyPath = NavigationPath()
    }

    // MARK: - Event Handlers
    private func setupNotificationListeners() {
        NotificationCenter.default.addObserver(
            forName: .brewSaved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleBrewSaved()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .coffeeSaved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleCoffeeSaved()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .coffeeUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleCoffeeUpdated()
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

        NotificationCenter.default.addObserver(
            forName: .openRatingSheet,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                if let brewID = notification.userInfo?["brewID"] as? UUID {
                    self?.openRatingSheet(brewID: brewID)
                }
            }
        }
    }

    private func handleBrewSaved() {
        popToRoot(for: .brew)
        _selectedTab = .brew
    }

    private func handleCoffeeSaved() {
        popToRoot(for: .add)
        _selectedTab = .brew
    }

    private func handleCoffeeUpdated() {
        editingCoffee = nil
    }

    private func handleRoasterSaved() {
        popToRoot(for: .add)
        _selectedTab = .brew
    }

    private func handleGrinderSaved() {
        popToRoot(for: .add)
        _selectedTab = .brew
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
