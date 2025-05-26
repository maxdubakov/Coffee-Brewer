import SwiftUI

struct RecipeHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
        }
        .padding(.horizontal, 18)
    }
}
