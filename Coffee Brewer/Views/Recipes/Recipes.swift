import SwiftUI
import CoreData

struct Recipes: View {
    // MARK: - Fetch Requests
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
            animation: .default
        )
    
    // MARK: - Private Properties
    private var roasters: FetchedResults<Roaster>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Recipes")
            ScrollView {
                ForEach(roasters) { roaster in
                    RoasterRecipes(roaster: roaster)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    GlobalBackground {
        Recipes()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
