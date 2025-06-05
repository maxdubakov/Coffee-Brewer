import SwiftUI

struct Preferences: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Preferences")
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
                // Temperature Units
                SettingsRow(
                    icon: "thermometer",
                    title: "Temperature Unit",
                    subtitle: "Celsius (°C)",
                    action: { },
                    showDivider: true,
                    isDisabled: true
                )
                
                // Default Brewing Settings
                SettingsRow(
                    icon: "slider.horizontal.3",
                    title: "Default Brewing Settings",
                    subtitle: "Set your preferred defaults",
                    action: { },
                    showDivider: true,
                    isDisabled: true
                )
                
                // Notifications
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Brew reminders and goals",
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
