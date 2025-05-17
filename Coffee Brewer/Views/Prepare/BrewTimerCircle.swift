import SwiftUI

struct BrewTimerCircle: View {
    // MARK: - Properties
    var elapsedTime: Double
    var pouredWater: Int16
    var totalTime: Double
    var totalWater: Int16
    var isRunning: Bool
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
        formatTime(elapsedTime)
    }
    
    private var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(BrewerColors.surface)
                .frame(width: circleSize, height: circleSize)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progressTimeValue)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.caramel.opacity(0.5), BrewerColors.caramel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: progressLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: circleSize - progressLineWidth, height: circleSize - progressLineWidth)
                .animation(.easeInOut(duration: 0.2), value: progressTimeValue)
            
            // Time display
            VStack(spacing: 8) {
                Text(formattedElapsedTime)
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                    .monospacedDigit()
                    .opacity(isRunning ? 1.0 : 0.2)
                    .animation(.easeInOut(duration: 0.2), value: isRunning)
                
                Text("\(pouredWater) ml")
                    .font(.system(size: 24))
                    .foregroundColor(BrewerColors.textSecondary)
                    .monospacedDigit()
                    .opacity(isRunning ? 1.0 : 0.2)
                    .animation(.easeInOut(duration: 0.2), value: isRunning)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }
            
            // Play/pause button overlay
            if !isRunning {
                Circle()
                    .fill(BrewerColors.cream.opacity(0.15))
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(BrewerColors.cream)
                    )
                    .frame(width: 100, height: 100)
                    .transition(.opacity)
            }
        }
        .onTapGesture {
            onToggle()
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    GlobalBackground {
        VStack {
            BrewTimerCircle(
                elapsedTime: 105,
                pouredWater: 40,
                totalTime: 225,
                totalWater: 280,
                isRunning: true,
                onToggle: {}
            )
            
            Spacer().frame(height: 50)
            
            BrewTimerCircle(
                elapsedTime: 45,
                pouredWater: 40,
                totalTime: 225,
                totalWater: 280,
                isRunning: false,
                onToggle: {}
            )
        }
        .padding()
    }
}
