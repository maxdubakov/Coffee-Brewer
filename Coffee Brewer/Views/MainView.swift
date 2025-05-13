import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case add
        case history
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area
            ZStack {
                switch selectedTab {
                case .home:
                    Recipes()
                        .padding(.top, 10)
                case .add:
                    AddRecipe()
                case .history:
                    Text("History Screen")
                        .font(.largeTitle)
                        .foregroundColor(BrewerColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom navigation bar
            BottomBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(BrewerColors.background)
    }
}

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
