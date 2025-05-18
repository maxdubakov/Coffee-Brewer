import SwiftUI

struct FormSliderField: View {
    @Binding var value: Int
    let from: Int
    let to: Int
    let title: String
    let color: Color
    
    var body: some View {
            FormField {
                VStack(spacing: 8) {
                    HStack {
                        SmallHeader(title: title)
                        
                        Spacer()
                        
                        Text("\(value)")
                            .foregroundColor(value > 0 ? color : BrewerColors.textSecondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    HStack(spacing: 24) {
                        Text(from.description)
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        Slider(value: Binding(
                            get: { Double(value) },
                            set: { value = Int($0) }
                        ), in: Double(from)...Double(to), step: 1)
                        .tint(color)
                        
                        Text(to.description)
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
            }
        }
    }
}

#Preview {
    struct FormSliderFieldPreviewWrapper: View {
        @State private var rating: Int = 3

        var body: some View {
            GlobalBackground {
                FormSliderField(
                    value: $rating,
                    from: 0,
                    to: 10,
                    title: "Sweetness",
                    color: BrewerColors.cream,
                ).padding(.horizontal, 40)
            }
        }
    }

    return FormSliderFieldPreviewWrapper()
}
