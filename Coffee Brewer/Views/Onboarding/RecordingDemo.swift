import SwiftUI

struct RecordingDemo: View {
    @StateObject private var onboardingState = OnboardingStateManager.shared
    @State private var currentStep = 0
    @State private var showDemo = true
    
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            if showDemo {
                OnboardingOverlay(onDismiss: handleSkip) {
                    VStack(spacing: 40) {
                        // Demo content based on step
                        Group {
                            switch currentStep {
                            case 0:
                                step1Content
                            case 1:
                                step2Content
                            case 2:
                                step3Content
                            case 3:
                                step4Content
                            case 4:
                                step5Content
                            default:
                                EmptyView()
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        
                        // Progress indicators and navigation
                        VStack(spacing: 20) {
                            // Progress dots
                            HStack(spacing: 8) {
                                ForEach(0..<5) { index in
                                    Circle()
                                        .fill(index == currentStep ? BrewerColors.amber : BrewerColors.cream.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(index == currentStep ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                                }
                            }
                            
                            // Navigation buttons
                            HStack(spacing: 16) {
                                if currentStep > 0 {
                                    StandardButton(
                                        title: "Back",
                                        action: previousStep,
                                        style: .secondary
                                    )
                                    .frame(width: 100)
                                }
                                
                                StandardButton(
                                    title: currentStep == 4 ? "Got it!" : "Next",
                                    action: nextStep,
                                    style: .primary
                                )
                                .frame(width: currentStep > 0 ? 100 : 200)
                            }
                            
                            Button("Skip tutorial") {
                                handleSkip()
                            }
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textSecondary)
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDemo)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
    }
    
    // MARK: - Step Content
    private var step1Content: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundColor(BrewerColors.amber)
                .symbolEffect(.bounce, value: currentStep)
            
            VStack(spacing: 12) {
                Text("Recording Your Pour")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BrewerColors.cream)
                
                Text("Learn how to record your coffee brewing stages in real-time")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var step2Content: some View {
        VStack(spacing: 20) {
            // Timer display mockup
            VStack(spacing: 8) {
                Text("00:00")
                    .font(.system(size: 60, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(BrewerColors.textPrimary)
                
                // Play button mockup
                ZStack {
                    Circle()
                        .fill(BrewerColors.surface.opacity(0.8))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BrewerColors.cream)
                }
            }
            
            VStack(spacing: 12) {
                Text("Start Recording")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
                
                Text("Tap the play button to start the timer when you begin brewing")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var step3Content: some View {
        VStack(spacing: 20) {
            // Pour type buttons mockup
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(BrewerColors.surface.opacity(0.8))
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {
                            SVGIcon("drop.fast", size: 28, color: BrewerColors.amber)
                            Text("Fast")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(BrewerColors.surface.opacity(0.8))
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {
                            SVGIcon("drop.slow", size: 28, color: BrewerColors.amber)
                            Text("Slow")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Record Your Pour")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
                
                Text("Tap Fast or Slow when you start pouring, then tap again to save the duration")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var step4Content: some View {
        VStack(spacing: 20) {
            // Recorded stages mockup
            VStack(spacing: 12) {
                HStack {
                    Text("Recorded Stages")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    // Stage examples
                    HStack {
                        SVGIcon("drop.fast", size: 16, color: BrewerColors.amber)
                        Text("Fast pour")
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textPrimary)
                        Spacer()
                        Text("8s")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(BrewerColors.surface.opacity(0.5))
                    .cornerRadius(8)
                    
                    HStack {
                        Image(systemName: "pause.circle")
                            .font(.system(size: 16))
                            .foregroundColor(BrewerColors.textSecondary)
                        Text("Wait")
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textPrimary)
                        Spacer()
                        Text("15s")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(BrewerColors.surface.opacity(0.5))
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .background(BrewerColors.surface.opacity(0.3))
            .cornerRadius(12)
            
            VStack(spacing: 12) {
                Text("Automatic Wait Stages")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
                
                Text("Time between pours is automatically tracked as Wait stages")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var step5Content: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(BrewerColors.amber)
                .symbolEffect(.bounce, value: currentStep)
            
            VStack(spacing: 12) {
                Text("Complete Your Recipe")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
                
                Text("After recording, you can fine-tune water amounts and timing for each stage")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Actions
    private func nextStep() {
        if currentStep < 4 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeDemo()
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
    
    private func handleSkip() {
        completeDemo()
    }
    
    private func completeDemo() {
        onboardingState.hasSeenRecordingDemo = true
        withAnimation {
            showDemo = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

#Preview {
    RecordingDemo(
        onComplete: {},
        onSkip: {}
    )
}