import SwiftUI

enum LibraryTab: String, CaseIterable {
    case all = "All"
    case recipes = "Recipes"
    case roasters = "Roasters" 
    case grinders = "Grinders"
    case brews = "Brews"
}

// MARK: - Library Tab Pills
struct LibraryTabButton: View {
    @Binding var selectedTab: LibraryTab
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 24) {
                ForEach(LibraryTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private func tabButton(for tab: LibraryTab) -> some View {
        let isSelected = selectedTab == tab
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 8) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? BrewerColors.cream : BrewerColors.textSecondary)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BrewerColors.caramel)
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "selector", in: animation)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Unified Library Header
struct LibraryHeader: View {
    @Binding var selectedTab: LibraryTab
    @Binding var showLibraryMode: Bool
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .top) {
            PageTitleH1(showLibraryMode ? "Library" : "Recipes", subtitle: showLibraryMode ? "Manage all your data here" : "Select a recipe to brew")
            
            Spacer()
            
            // Toggle Button (Library/Recipes)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showLibraryMode.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(showLibraryMode ? "Recipes" : "Library")
                        .font(.system(size: 13, weight: .semibold))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(BrewerColors.cream)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            BrewerColors.mocha.opacity(0.9),
                            BrewerColors.espresso.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    BrewerColors.caramel.opacity(0.5),
                                    BrewerColors.caramel.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Legacy component for backwards compatibility
struct LibraryNavigationHeader: View {
    @Binding var selectedTab: LibraryTab
    @Binding var showLibraryMode: Bool
    
    var body: some View {
        LibraryHeader(selectedTab: $selectedTab, showLibraryMode: $showLibraryMode)
    }
}
