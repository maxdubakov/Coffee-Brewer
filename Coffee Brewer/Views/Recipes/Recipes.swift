import SwiftUI
import CoreData

struct Recipes: View {
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
            animation: .default
        )
    private var roasters: FetchedResults<Roaster>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: "Recipes")
                ForEach(roasters) { roaster in
                    RoasterRecipes(roaster: roaster)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    GlobalBackground {
        Recipes()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
