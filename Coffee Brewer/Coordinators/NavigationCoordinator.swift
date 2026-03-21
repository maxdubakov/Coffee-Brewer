import SwiftUI
import CoreData

// MARK: - Navigation Destinations
enum AppDestination: Hashable {
    // Add flow
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
    @Published private var _selectedTab: Main.Tab = .home

    var selectedTab: Binding<Main.Tab> {
        Binding(
            get: { self._selectedTab },
            set: { newValue in
                self._selectedTab = newValue
            }
        )
    }

    // MARK: - Navigation Paths
    @Published var homePath = NavigationPath()
    @Published var addPath = NavigationPath()
    @Published var historyPath = NavigationPath()

    // MARK: - Modal States
    @Published var editingRoaster: Roaster?
    @Published var editingGrinder: Grinder?

    // MARK: - Delete Roaster State
    @Published var showingDeleteRoasterAlert = false
    @Published var roasterToDelete: Roaster?

    // MARK: - Delete Grinder State
    @Published var showingDeleteGrinderAlert = false
    @Published var grinderToDelete: Grinder?

    // MARK: - Delete Brew State
    @Published var showingDeleteBrewAlert = false
    @Published var brewToDelete: Brew?

    init() {
        setupNotificationListeners()
    }

    // MARK: - Navigation Methods
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

    func navigateToLibraryBrews() {
        _selectedTab = .home
        NotificationCenter.default.post(name: .navigateToLibraryBrews, object: nil)
    }

    func navigateToHome() {
        _selectedTab = .home
    }

    func navigateToSettings() {
        homePath.append(AppDestination.settings)
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

    // MARK: - Event Handlers
    private func setupNotificationListeners() {
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
    static let navigateToLibraryBrews = Notification.Name("navigateToLibraryBrews")
}
