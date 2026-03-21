import SwiftUI

struct Main: View {
    // MARK: - Nested Types
    enum Tab {
        case home, brew, add, history
    }

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Navigation
    @StateObject private var navigationCoordinator = NavigationCoordinator()

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
            // Home tab
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

            // Brew tab — picker is the root, pushes to BrewEditor
            NavigationStack(path: $navigationCoordinator.brewPath) {
                BrewPicker()
                    .background(BrewerColors.background)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
                    .navigationDestination(for: BrewEditorRoute.self) { route in
                        brewEditorView(for: route)
                    }
            }
            .tabItem {
                TabIcon(imageName: "brew", label: "Brew")
            }
            .tag(Tab.brew)

            // Add tab
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

            // History tab
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
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(BrewerColors.background)
            appearance.shadowColor = .clear

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .environmentObject(navigationCoordinator)
    }

    // MARK: - Brew Editor Destination Handler
    @ViewBuilder
    private func brewEditorView(for route: BrewEditorRoute) -> some View {
        switch route {
        case .template(let method):
            BrewEditor(startingPoint: .template(method), context: viewContext)
        case .cloneFromBrew(let objectID):
            if let brew = try? viewContext.existingObject(with: objectID) as? Brew {
                BrewEditor(startingPoint: .cloneFromBrew(brew), context: viewContext)
            } else {
                // Brew was deleted before navigation completed — return to picker
                Color.clear.onAppear {
                    navigationCoordinator.popToRoot(for: .brew)
                }
            }
        }
    }

    // MARK: - Navigation Destination Handler
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .addCoffee:
            AddCoffee(context: viewContext)

        case .addRoaster:
            AddRoaster(context: viewContext)

        case .addGrinder:
            AddGrinder(context: viewContext)

        case .brewDetail(let brewID):
            if let brew = try? viewContext.existingObject(with: brewID) as? Brew {
                BrewDetailSheet(brew: brew)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Brew not found")
            }

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
