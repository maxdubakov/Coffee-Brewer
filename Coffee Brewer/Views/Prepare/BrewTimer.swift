import SwiftUI

struct BrewTimer: View {
    // MARK: - Properties
    var elapsedTime: Double
    var pouredWater: Int16
    var totalTime: Double
    var onToggle: () -> Void
    
    // MARK: - Private Properties
    private let circleSize: CGFloat = 280
    private let progressLineWidth: CGFloat = 8
    
    // MARK: - Computed Properties
    private var progressTimeValue: Double {
        guard totalTime > 0 else { return 0 }
        return min(1.0, elapsedTime / totalTime)
    }
    
    private var formattedElapsedTime: String {
        elapsedTime.formattedTime
    }
    
    private var formattedTotalTime: String {
        totalTime.formattedTime
    }
    
    var body: some View {
            // Time display
            VStack(spacing: 8) {
                Text(formattedElapsedTime)
                    .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(BrewerColors.textPrimary)
                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                
                Text("\(pouredWater) ml")
                    .font(.system(size: 30, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(BrewerColors.textSecondary)
            }
    }
    
}

// MARK: - Preview
#Preview {
    GlobalBackground {
        VStack {
            BrewTimer(
                elapsedTime: 105,
                pouredWater: 40,
                totalTime: 225,
                onToggle: {}
            )
        }
    }
}
