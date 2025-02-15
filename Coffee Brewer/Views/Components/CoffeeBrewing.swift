import SwiftUI

struct CoffeeBrewing: View {
  @State private var coffeeAmount: String = "18"
  @State private var selectedStrength: CoffeeStrength = .strong
  @State private var isShowingResults = true
  @State private var animateStages = true
  
  
  var body: some View {
    ZStack {
      CoffeeColors.accent
        .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 30) {
          // Input section
          VStack(spacing: 15) {
            Text(CoffeePrompts.selectedPrompt)
              .foregroundColor(CoffeeColors.text)
              .font(.headline)
              .padding(20)
            
            CoffeeAmountPicker(coffeeAmount: $coffeeAmount)
              .padding(.horizontal)
            
            
          }
          .padding(.horizontal)
          
          StrengthSelector(selectedStrength: $selectedStrength)
            .padding(.horizontal)
          
          WaterToRatioTable(
            coffeeAmount: coffeeAmount,
            selectedStrength: selectedStrength
          ).padding(.horizontal)
          
          BrewingTimer().padding(.horizontal)
          
          Spacer(minLength: 0)
        }
        .padding(.horizontal)
      }
    }
  }
}

#Preview {
  CoffeeBrewing()
}
