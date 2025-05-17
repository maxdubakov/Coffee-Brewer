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
    @State private var selectedRecipe: Recipe? = nil
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrewerColors.background)
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Recipes(selectedTab: $selectedTab, selectedRoaster: $selectedRoaster, selectedRecipe: $selectedRecipe)
                .background(BrewerColors.background)
                .tabItem {
                    TabIcon(imageName: "home", label: "Home")
                }
                .tag(Tab.home)

            AddRecipe(
                existingRoaster: selectedRoaster,
                context: viewContext,
                selectedTab: $selectedTab,
                existingRecipe: selectedRecipe,
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
