import SwiftUI

struct BrewingTimer: View {
  @State private var timeElapsed: TimeInterval = 0
  @State private var timer: Timer?
  @State private var isRunning = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Timer")
        .font(.headline)
        .foregroundColor(CoffeeColors.text)
      
      HStack {
        Text(timeString(from: timeElapsed))
          .font(.system(.title2, design: .monospaced))
          .fontWeight(.medium)
          .foregroundColor(CoffeeColors.primary)
        
        Spacer()
        
        HStack(spacing: 8) {
          // Reset button
          Image(systemName: "stop.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(CoffeeColors.primary)
            .contentShape(Rectangle())
            .onTapGesture {
              resetTimer()
            }
          
          // Play/Pause button
          Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(CoffeeColors.primary)
            .contentShape(Rectangle())
            .onTapGesture {
              isRunning.toggle()
              if isRunning {
                startTimer()
              } else {
                stopTimer()
              }
            }
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(Color.white)
          .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
      )
    }
  }
  
  private func timeString(from timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)
    return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
  }
  
  private func startTimer() {
    // Update every 1/100th of a second for smooth milliseconds display
    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
      timeElapsed += 0.01
    }
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func resetTimer() {
    stopTimer()
    timeElapsed = 0
    isRunning = false
  }
}
