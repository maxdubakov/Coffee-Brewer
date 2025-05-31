import SwiftUI

enum RecipeGrouping: String, CaseIterable {
    case byRoaster = "By Roaster"
    case byGrinder = "By Grinder"
}

struct RecipeGroupFilter: View {
    @Binding var selectedGrouping: RecipeGrouping
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(RecipeGrouping.allCases, id: \.self) { grouping in
                filterButton(for: grouping)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .background(BrewerColors.cardBackground)
    }
    
    @ViewBuilder
    private func filterButton(for grouping: RecipeGrouping) -> some View {
        let isSelected = selectedGrouping == grouping
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedGrouping = grouping
            }
        }) {
            VStack(spacing: 8) {
                Text(grouping.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
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
