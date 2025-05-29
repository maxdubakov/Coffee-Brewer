import SwiftUI

enum LibraryTab: String, CaseIterable {
    case recipes = "Recipes"
    case roasters = "Roasters" 
    case grinders = "Grinders"
}

struct LibraryNavigationHeader: View {
    @Binding var selectedTab: LibraryTab
    @Binding var showLibraryMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Premium Header Bar
            HStack(alignment: .center, spacing: 16) {
                // Library Title with icon
                HStack(spacing: 8) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(BrewerColors.caramel)
                    
                    Text("Library")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(BrewerColors.cream)
                }
                
                Spacer()
                
                // Tab Pills
                HStack(spacing: 4) {
                    ForEach(LibraryTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .medium))
                                .foregroundColor(selectedTab == tab ? BrewerColors.cream : BrewerColors.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTab == tab ? BrewerColors.caramel : Color.clear)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
                                )
                        }
                    }
                }
                
                // Close/Recipes Toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showLibraryMode = false
                    }
                }) {
                    Text("Recipes")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BrewerColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(BrewerColors.textSecondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .background(
            ZStack {
                // Base background with blur effect
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [
                                BrewerColors.cardBackground.opacity(0.98),
                                BrewerColors.cardBackground.opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Subtle border
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    BrewerColors.caramel.opacity(0.2),
                                    BrewerColors.caramel.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                }
            }
        )
    }
}
