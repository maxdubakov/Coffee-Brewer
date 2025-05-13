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
                case .add:
                    Text("Add Recipe")
                        .font(.largeTitle)
                        .foregroundColor(CoffeeColors.accent)
                case .history:
                    Text("History Screen")
                        .font(.largeTitle)
                        .foregroundColor(CoffeeColors.accent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom navigation bar
            BottomBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(red: 0.03, green: 0.03, blue: 0.03))
    }
}

#Preview {
    MainView()
}
