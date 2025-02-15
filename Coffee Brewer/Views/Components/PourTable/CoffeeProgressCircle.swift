import SwiftUI

struct CoffeeProgressCircle: View {
  let progress: Double // 0.0 to 1.0
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Border circle
        Circle()
          .stroke(CoffeeColors.primary, lineWidth: 2)
        
        if progress >= 1.0 {
          // Show completion symbol
          Circle()
            .foregroundColor(CoffeeColors.primary)
          Image(systemName: "sparkles")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
        } else {
          // Coffee fill with static wave
          Circle()
            .clipShape(
              WaveShape(
                progress: progress,
                waveHeight: 2
              )
            )
            .foregroundColor(CoffeeColors.primary)
        }
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(width: 32, height: 32)
  }
}
