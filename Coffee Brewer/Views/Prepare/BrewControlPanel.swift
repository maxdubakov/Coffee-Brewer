import SwiftUI

struct BrewControlPanel: View {
    // MARK: - Properties
    @Binding var isRunning: Bool
    @Binding var currentStageIndex: Int
    
    let totalStages: Int
    let onTogglePlay: () -> Void
    let onRestart: () -> Void
    let onSkipForward: (() -> Void)?
    let onSkipBackward: (() -> Void)?
    let showSkipButtons: Bool
    let isDisabled: Bool
    
    // MARK: - Initializers
    init(
        isRunning: Binding<Bool>,
        currentStageIndex: Binding<Int>,
        totalStages: Int,
        onTogglePlay: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        onSkipForward: (() -> Void)? = nil,
        onSkipBackward: (() -> Void)? = nil,
        showSkipButtons: Bool = true,
        isDisabled: Bool = false
    ) {
        self._isRunning = isRunning
        self._currentStageIndex = currentStageIndex
        self.totalStages = totalStages
        self.onTogglePlay = onTogglePlay
        self.onRestart = onRestart
        self.onSkipForward = onSkipForward
        self.onSkipBackward = onSkipBackward
        self.showSkipButtons = showSkipButtons
        self.isDisabled = isDisabled
    }
    
    // Convenience initializer for when skip buttons aren't needed
    init(
        isRunning: Binding<Bool>,
        onTogglePlay: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        isDisabled: Bool = false
    ) {
        self._isRunning = isRunning
        self._currentStageIndex = .constant(0)
        self.totalStages = 1
        self.onTogglePlay = onTogglePlay
        self.onRestart = onRestart
        self.onSkipForward = nil
        self.onSkipBackward = nil
        self.showSkipButtons = false
        self.isDisabled = isDisabled
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(BrewerColors.surface.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(BrewerColors.caramel.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                
                Rectangle()
                    .fill(BrewerColors.divider)
                    .frame(width: 1)
                    .padding(.vertical, 12)
                
                HStack(spacing: 0) {
                    Button(action: onRestart) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(isDisabled ? BrewerColors.cream.opacity(0.3) : BrewerColors.cream)
                            .frame(width: 60, height: 56)
                    }
                    .disabled(isDisabled)
                    
                    Button(action: onTogglePlay) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(isDisabled ? BrewerColors.caramel.opacity(0.3) : BrewerColors.caramel)
                            .frame(width: 60, height: 56)
                    }
                    .disabled(isDisabled)
                }
            }
            .frame(width: 120, height: 56)
            
            if showSkipButtons {
                HStack(spacing: 0) {
                    Button(action: { onSkipBackward?() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(currentStageIndex > 0 ? BrewerColors.cream : BrewerColors.cream.opacity(0.4))
                            .frame(width: 32, height: 24)
                    }
                    .disabled(currentStageIndex <= 0)
                    
                    Spacer()
                        .frame(width: 150)
                    
                    Button(action: { onSkipForward?() }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(currentStageIndex < totalStages - 1 ? BrewerColors.cream : BrewerColors.cream.opacity(0.4))
                            .frame(width: 32, height: 24)
                    }
                    .disabled(currentStageIndex >= totalStages - 1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview
struct BrewControlPanelPreview: PreviewProvider {
   static var previews: some View {
       struct PreviewWrapper: View {
           @State private var isRunning = false
           @State private var currentStageIndex = 1
           let totalStages = 4
           
           var body: some View {
               ZStack {
                   BrewerColors.background.edgesIgnoringSafeArea(.all)
                   
                   VStack(spacing: 40) {
                       // With skip buttons
                       BrewControlPanel(
                           isRunning: $isRunning,
                           currentStageIndex: $currentStageIndex,
                           totalStages: totalStages,
                           onTogglePlay: { isRunning.toggle() },
                           onRestart: { currentStageIndex = 0 },
                           onSkipForward: {
                               if currentStageIndex < totalStages - 1 {
                                   currentStageIndex += 1
                               }
                           },
                           onSkipBackward: {
                               if currentStageIndex > 0 {
                                   currentStageIndex -= 1
                               }
                           },
                           showSkipButtons: true
                       )
                       
                       // Without skip buttons
                       BrewControlPanel(
                           isRunning: $isRunning,
                           onTogglePlay: { isRunning.toggle() },
                           onRestart: { isRunning = false }
                       )
                       
                       Text("Current Stage: \(currentStageIndex + 1)")
                           .foregroundColor(BrewerColors.textPrimary)
                       
                       Text("Playing: \(isRunning ? "Yes" : "No")")
                           .foregroundColor(BrewerColors.textPrimary)
                   }
                   .padding()
               }
           }
       }
       
       return PreviewWrapper()
   }
}
