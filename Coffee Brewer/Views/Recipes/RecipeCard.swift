import SwiftUI

struct RecipeCard: View {
    var title: String
    var timeAgo: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(BrewerColors.textPrimary.opacity(0.5))
                    .frame(width: 169, height: 169)
                    .overlay(
                        Text("⾖")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(BrewerColors.textPrimary)
                        .frame(minWidth: 99, alignment: .leading)

                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(BrewerColors.textSecondary)
                        .frame(minWidth: 99, alignment: .leading)
                }
                .padding(14)
            }
            .background(BrewerColors.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GlobalBackground {
        RecipeCard(
            title: "Sample Recipe",
            timeAgo: "2 days ago",
            onTap: {}
        )
        .frame(width: 200, height: 250)
    }
}
