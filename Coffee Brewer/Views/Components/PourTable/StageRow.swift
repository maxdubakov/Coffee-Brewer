import SwiftUI

struct StageRow: View {
  let stage: Int
  let amount: Double
  let cumulativeAmount: Double
  let total: Double
  let isVisible: Bool
  
  var body: some View {
    HStack {
      CoffeeProgressCircle(
        progress: cumulativeAmount / total
      )
      
      VStack(alignment: .leading, spacing: 5) {
        Text("\(Int(round(cumulativeAmount)))ml")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(CoffeeColors.primary)
      }
      
      Spacer()
      
      Text("(+\(Int(round(amount)))ml)")
        .font(.subheadline)
        .foregroundColor(CoffeeColors.text.opacity(0.6))
    }
    .padding(.vertical, 6)
    .opacity(isVisible ? 1 : 0)
    .offset(x: isVisible ? 0 : -50)
    .animation(.easeOut(duration: 0.5).delay(Double(stage) * 0.2), value: isVisible)
  }
}
