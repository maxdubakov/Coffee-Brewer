import SwiftUI
import CoreData

struct AddRecipeCoordinatorView: View {
    @ObservedObject var coordinator: AddRecipeCoordinator
    @Binding var selectedRoaster: Roaster?
    let context: NSManagedObjectContext
    @Binding var selectedTab: MainView.Tab
    
    @State private var addRecipeView: AddRecipe?
    
    var body: some View {
        Group {
            if let view = addRecipeView {
                view
            } else {
                Color.clear
                    .onAppear {
                        let view = AddRecipe(
                            selectedTab: $selectedTab,
                            selectedRoaster: $selectedRoaster,
                            context: context
                        )
                        addRecipeView = view
                        coordinator.setAddRecipeView(view)
                    }
            }
        }
    }
}