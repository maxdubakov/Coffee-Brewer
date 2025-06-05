import SwiftUI

struct Tutorial: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Help & Support")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Spacer()
                
                // Coming soon badge
                Text("COMING SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(BrewerColors.caramel.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(BrewerColors.caramel.opacity(0.15))
                    )
            }
            
            VStack(spacing: 0) {
                // Tutorial
                SettingsRow(
                    icon: "graduationcap",
                    title: "Tutorial",
                    subtitle: "Learn brewing basics",
                    action: { },
                    showDivider: true,
                    isDisabled: true
                )
                
                // Reset Onboarding
                SettingsRow(
                    icon: "arrow.clockwise",
                    title: "Reset Tutorial",
                    subtitle: "Start onboarding again",
                    action: { },
                    showDivider: true,
                    isDisabled: true
                )
                
                // Feedback
                SettingsRow(
                    icon: "envelope",
                    title: "Send Feedback",
                    subtitle: "Help us improve the app",
                    action: { },
                    showDivider: false,
                    isDisabled: true
                )
            }
            .background(BrewerColors.cardBackground.opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                BrewerColors.divider.opacity(0.3),
                                BrewerColors.divider.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
        }
    }
}
