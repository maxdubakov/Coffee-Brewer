import SwiftUI

struct StrengthSelector: View {
  @Binding var selectedStrength: CoffeeStrength
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Coffee Strength")
        .font(.headline)
        .foregroundColor(CoffeeColors.text)
      
      HStack(spacing: 12) {
        ForEach(CoffeeStrength.allCases, id: \.self) { strength in
          VStack(spacing: 4) {
            Text(strength.rawValue)
              .font(.subheadline)
              .fontWeight(.medium)
            Text(strength.description)
              .font(.caption)
          }
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(selectedStrength == strength ?
                    CoffeeColors.primary : Color.white)
          )
          .foregroundColor(selectedStrength == strength ?
            .white : CoffeeColors.text)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(CoffeeColors.secondary, lineWidth: 1)
          )
          .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
              selectedStrength = strength
            }
          }
        }
      }
    }
  }
}
