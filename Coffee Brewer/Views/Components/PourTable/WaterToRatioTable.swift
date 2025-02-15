import SwiftUI

struct WaterToRatioTable: View {
  let coffeeAmount: String
  let selectedStrength: CoffeeStrength
  
  private func calculateWaterStages(coffeeGrams: Double) -> [(stage: Int, amount: Double, cumulativeAmount: Double)] {
    let totalWater = coffeeGrams * selectedStrength.ratio
    
    let percentages = [0.23, 0.23, 0.31, 0.23]
    var stages: [(stage: Int, amount: Double, cumulativeAmount: Double)] = []
    var runningTotal = 0.0
    
    for (index, percentage) in percentages.enumerated() {
      let currentTotal = totalWater * percentages[0...index].reduce(0, +)
      let roundedCumulativeTarget = round(currentTotal)
      let roundedAmount = roundedCumulativeTarget - runningTotal
      runningTotal += roundedAmount
      stages.append((index + 1, roundedAmount, runningTotal))
    }
    
    return stages
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Pour Process")
        .font(.headline)
        .foregroundColor(CoffeeColors.text)
      
      let coffeeGrams = Double(coffeeAmount) ?? 0
      let stages = calculateWaterStages(coffeeGrams: coffeeGrams)
      let total = stages.reduce(0) { $0 + $1.amount }
      
      VStack(spacing: 16) {
        HStack {
          Text("Water-to-Coffee Ratio:")
            .font(.subheadline)
            .foregroundColor(CoffeeColors.text.opacity(0.8))
          Spacer()
          Text("1:\(String(format: "%.1f", selectedStrength.ratio))")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(CoffeeColors.primary)
        }
        
        ForEach(stages, id: \.stage) { stage in
          StageRow(
            stage: stage.stage,
            amount: stage.amount,
            cumulativeAmount: stage.cumulativeAmount,
            total: total,
            isVisible: true
          )
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(Color.white)
          .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
      )
      .opacity(coffeeGrams > 0 ? 1 : 0.5)
    }
  }
}
