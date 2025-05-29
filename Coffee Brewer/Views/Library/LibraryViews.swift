import SwiftUI

// MARK: - Recipes Library View
struct RecipesLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("All Recipes")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BrewerColors.cream)
            
            Text("Recipe management coming soon...")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Roasters Library View
struct RoastersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Roaster Management")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BrewerColors.cream)
            
            Text("Roaster management coming soon...")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Grinders Library View
struct GrindersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Grinder Management")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BrewerColors.cream)
            
            Text("Grinder management coming soon...")
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}