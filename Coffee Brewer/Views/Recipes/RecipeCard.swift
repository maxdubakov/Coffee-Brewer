import SwiftUI

struct RecipeCard: View {
    var title: String
    var timeAgo: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Recipe Image Placeholder
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 169, height: 169)
                    .background(BrewerColors.textPrimary.opacity(0.5))

                // Recipe Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(BrewerColors.textPrimary)
                        .frame(minWidth: 99, alignment: .leading)

                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(BrewerColors.textPrimary.opacity(0.7))
                        .frame(minWidth: 99, alignment: .leading)
                }
                .padding(14)
            }
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RecipeCard(
        title: "Sample Recipe",
        timeAgo: "2 days ago",
        onTap: {}
    )
    .frame(width: 200, height: 250)
    .background(Color(red: 0.05, green: 0.03, blue: 0.01))
}
