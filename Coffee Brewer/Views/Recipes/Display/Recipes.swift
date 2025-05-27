import SwiftUI
import CoreData

struct Recipes: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    // MARK: - Fetch Requests
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
            animation: .default
        )
    
    // MARK: - Private Properties
    private var roasters: FetchedResults<Roaster>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack {
                    ForEach(roasters) { roaster in
                        RoasterRecipes(roaster: roaster, navigationCoordinator: navigationCoordinator)
                    }
                    Spacer().frame(height: 80)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .scrollIndicators(.hidden)
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    GlobalBackground {
        Recipes(navigationCoordinator: NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
