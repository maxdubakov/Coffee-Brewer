import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, add, history
    }

    var body: some View {
            TabView(selection: $selectedTab) {
                Recipes()
                    .background(BrewerColors.background)
                    .tabItem {
                        TabIcon(imageName: "home", label: "Home")
                    }
                    .tag(Tab.home)

                AddRecipe(context: viewContext, selectedTab: $selectedTab)
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
            .background(BrewerColors.background)
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
