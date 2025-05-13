import SwiftUI
import CoreData

struct Recipes: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
            animation: .default)
        private var roasters: FetchedResults<Roaster>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("Recipes")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(CoffeeColors.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 28)
                }
                .background(Color(red: 0.05, green: 0.03, blue: 0.01))

                // Recipe Collection
                ForEach(roasters) {
                    roaster in RoasterRecipes(roaster: roaster)
                }
                .background(Color(red: 0.05, green: 0.03, blue: 0.01))
            }
            .background(Color(red: 0.05, green: 0.03, blue: 0.01))
        }
        .background(Color(red: 0.03, green: 0.03, blue: 0.03))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Recipes()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
