import SwiftUI

struct FormRatingField: View {
    
    let field: FocusedField
    
    // MARK: - Bindings
    @Binding var value: Double
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        HStack(spacing: 16) {
            FormField {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(value) ? "star.fill" : "star")
                        .foregroundColor(star <= Int(value) ? BrewerColors.caramel : BrewerColors.textSecondary)
                        .font(.system(size: 30))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                value = Double(star)
                            }
                        }
                }
            }
        }
        .onTapGesture {
            focusedField = field
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    struct FormRatingFieldPreviewWrapper: View {
        @State private var rating: Double = 3.0

        var body: some View {
            GlobalBackground {
                FormRatingField(
                    field: .brewRating,
                    value: $rating,
                    focusedField: .constant(nil),
                )
            }
        }
    }

    return FormRatingFieldPreviewWrapper()
}
