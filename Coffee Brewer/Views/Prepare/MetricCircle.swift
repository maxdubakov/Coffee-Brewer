import SwiftUI

struct MetricCircle: View {
    // MARK: - Properties
    var value: String
    var label: String
    var color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .overlay(
                        Circle()
                            .strokeBorder(color.opacity(0.5), lineWidth: 1.5)
                    )
                    .frame(width: 54, height: 54)
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
            }
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white)
        }
    }
}
