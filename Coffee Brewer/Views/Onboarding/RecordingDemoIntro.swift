import SwiftUI

struct RecordingDemoIntro: View {
    let onShowDemo: () -> Void
    let onSkip: () -> Void
    
    @State private var iconScale = 0.8
    @State private var iconOpacity = 0.0
    
    var body: some View {
        VStack {
            // Top section with icon and title
            VStack(spacing: 24) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(BrewerColors.amber.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .opacity(iconOpacity)
                    
                    // Timer icon
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    BrewerColors.amber,
                                    BrewerColors.amber.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                }
                .frame(height: 120)
                
                VStack(spacing: 12) {
                    Text("Learn Recording")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BrewerColors.cream, BrewerColors.cream.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("Want to see how to record your coffee brewing stages?")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 220)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    iconScale = 1.0
                    iconOpacity = 1.0
                }
            }
            
            Spacer(minLength: 20)
            
            // Info box
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(BrewerColors.amber)
                    
                    Text("Quick Tutorial")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Record pour stages in real-time")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                    
                    Text("• Automatic wait time tracking")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                    
                    Text("• Fine-tune water amounts later")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(BrewerColors.surface.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(BrewerColors.divider.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 10)
            
            Spacer(minLength: 20)
            
            // Bottom section with buttons
            VStack(spacing: 12) {
                StandardButton(
                    title: "Show Me How",
                    action: onShowDemo,
                    style: .primary
                )
                
                StandardButton(
                    title: "Skip Tutorial",
                    action: onSkip,
                    style: .secondary
                )
            }
        }
        .frame(height: 400)
    }
}

#Preview {
    OnboardingOverlay(onDismiss: {}) {
        RecordingDemoIntro(
            onShowDemo: {},
            onSkip: {}
        )
    }
    .background(Color.black)
}