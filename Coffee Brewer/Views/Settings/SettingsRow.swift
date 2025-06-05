import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    let showDivider: Bool
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: isDisabled ? {} : action) {
                HStack(spacing: 16) {
                    // Premium icon with subtle background
                    ZStack {
                        Circle()
                            .fill(isDisabled ? BrewerColors.divider.opacity(0.3) : BrewerColors.caramel.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isDisabled ? BrewerColors.textSecondary.opacity(0.4) : BrewerColors.caramel)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDisabled ? BrewerColors.textSecondary.opacity(0.5) : BrewerColors.textPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(isDisabled ? BrewerColors.textSecondary.opacity(0.3) : BrewerColors.textSecondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isDisabled ? BrewerColors.textSecondary.opacity(0.2) : BrewerColors.textSecondary.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDisabled)
            
            if showDivider {
                CustomDivider()
                    .opacity(0.5)
                    .padding(.leading, 68)
            }
        }
    }
}
