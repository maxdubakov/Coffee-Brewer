import SwiftUI

struct CoffeeAmountPicker: View {
  @Binding var coffeeAmount: String
  
  // Generate array of possible coffee amounts (1-50 grams)
  let amounts = Array(1...100).map { String($0) }
  
  var body: some View {
    Picker("Coffee Amount", selection: $coffeeAmount) {
      ForEach(amounts, id: \.self) { amount in
        Text("\(amount)g")
          .tag(amount)
          .foregroundColor(CoffeeColors.primary)
      }
    }
    .pickerStyle(.wheel)
    .frame(width: 100, height: 160)
    
  }
}
