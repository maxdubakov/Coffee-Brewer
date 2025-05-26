import SwiftUI
import CoreData

struct Recipes: View {
    @Binding var selectedTab: Main.Tab
    @Binding var selectedRoaster: Roaster?
    
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
                .padding(.horizontal, 18)
            ScrollView {
                VStack {
                    ForEach(roasters) { roaster in
                        RoasterRecipes(roaster: roaster, selectedTab: $selectedTab, selectedRoaster: $selectedRoaster)
                    }
                    Spacer().frame(height: 80)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    GlobalBackground {
        Recipes(selectedTab: .constant(.home), selectedRoaster: .constant(nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
