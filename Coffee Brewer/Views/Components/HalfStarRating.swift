import SwiftUI

/// A reusable 5-star rating component that supports 0.5-step precision.
/// Tapping the left half of a star sets rating to x.5; right half sets x.0.
struct HalfStarRating: View {
    @Binding var rating: Double
    var starSize: CGFloat = 28
    var spacing: CGFloat = 6

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5, id: \.self) { index in
                starView(for: index)
            }
        }
    }

    // MARK: - Private

    private func starView(for index: Int) -> some View {
        let symbolName = symbolName(for: index)
        let isFilled = rating >= Double(index) + 0.5

        return Image(systemName: symbolName)
            .font(.system(size: starSize))
            .foregroundColor(isFilled ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.3))
            .overlay(
                HStack(spacing: 0) {
                    // Left half → x.5
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { rating = Double(index) + 0.5 }
                    // Right half → whole number
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { rating = Double(index) + 1.0 }
                }
            )
    }

    private func symbolName(for index: Int) -> String {
        if rating >= Double(index) + 1.0 {
            return "star.fill"
        } else if rating >= Double(index) + 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Preview

#Preview("Half-Star Rating") {
    VStack(spacing: 24) {
        HalfStarRating(rating: .constant(0))
        HalfStarRating(rating: .constant(2.5))
        HalfStarRating(rating: .constant(3.0))
        HalfStarRating(rating: .constant(4.5))
        HalfStarRating(rating: .constant(5.0))
    }
    .padding()
    .background(BrewerColors.background)
}
