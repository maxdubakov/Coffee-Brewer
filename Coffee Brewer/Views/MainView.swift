import SwiftUI

struct MainView: View {
    enum Tab {
        case home, add, history
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Recipes()
                .tabItem {
                    TabIcon(imageName: "home", label: "Home")
                }
                .tag(Tab.home)

            AddRecipe()
                .tabItem {
                    TabIcon(imageName: "add.recipe", label: "Add")
                }
                .tag(Tab.add)

            History()
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
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
