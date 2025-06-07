import SwiftUI

// MARK: - Choice Card Style
enum ChoiceCardStyle {
    case primary
    case secondary
}

// MARK: - Choice Card
struct ChoiceCard: View {
    let title: String
    let description: String
    let icon: IconType
    let style: ChoiceCardStyle
    let badgeText: String?
    let disabled: Bool
    let action: () -> Void
    
    enum IconType {
        case svg(String)
        case system(String)
    }
    
    init(
        title: String,
        description: String,
        icon: IconType,
        style: ChoiceCardStyle = .primary,
        badgeText: String? = nil,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.style = style
        self.badgeText = badgeText
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !disabled {
                action()
            }
        }) {
            if style == .primary {
                primaryContent
            } else {
                secondaryContent
            }
        }
        .disabled(disabled)
        .buttonStyle(ChoiceCardButtonStyle())
    }
    
    // MARK: - Primary Style
    private var primaryContent: some View {
        VStack(spacing: 20) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.caramel.opacity(0.8), BrewerColors.caramel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(BrewerColors.caramel, lineWidth: 2)
                    )
                    .shadow(color: BrewerColors.buttonShadow, radius: 6, x: 0, y: 3)
                
                iconView(size: 40, color: BrewerColors.cream)
            }
            
            // Text Content
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                if let badgeText = badgeText, !badgeText.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text(badgeText)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(BrewerColors.caramel)
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(primaryBackground)
    }
    
    private var primaryBackground: some View {
        ZStack {
            // Base background
            BrewerColors.surface
            
            // Premium gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    BrewerColors.caramel.opacity(0.15),
                    BrewerColors.caramel.opacity(0.05),
                    Color.clear,
                    BrewerColors.cream.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle radial gradient for depth
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 10,
                endRadius: 200
            )
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(BrewerColors.caramel.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: BrewerColors.caramel.opacity(0.15), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.3), radius: 40, x: 0, y: 20)
    }
    
    // MARK: - Secondary Style
    private var secondaryContent: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(disabled ? BrewerColors.surface.opacity(0.5) : BrewerColors.surface)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                disabled ? BrewerColors.divider.opacity(0.5) : BrewerColors.divider,
                                lineWidth: 1.5
                            )
                    )
                
                iconView(
                    size: 24,
                    color: disabled ? BrewerColors.textSecondary.opacity(0.5) : BrewerColors.cream
                )
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(disabled ? BrewerColors.textSecondary.opacity(0.5) : BrewerColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(disabled ? BrewerColors.textSecondary.opacity(0.3) : BrewerColors.textSecondary)
            }
            
            Spacer()
            
            if !disabled {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary)
            }
        }
        .padding(20)
        .background(secondaryBackground)
    }
    
    private var secondaryBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            disabled ? BrewerColors.cardBackground.opacity(0.3) : BrewerColors.cardBackground,
                            disabled ? BrewerColors.cardBackground.opacity(0.2) : BrewerColors.cardBackground.opacity(0.9),
                            disabled ? BrewerColors.caramel.opacity(0.03) : BrewerColors.caramel.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            disabled ? Color.white.opacity(0.02) : Color.white.opacity(0.1),
                            disabled ? Color.white.opacity(0.01) : Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: disabled ? Color.clear : Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Icon View Helper
    @ViewBuilder
    private func iconView(size: CGFloat, color: Color) -> some View {
        switch icon {
        case .svg(let name):
            SVGIcon(name, size: size, color: color)
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: size))
                .foregroundColor(color)
        }
    }
}

// MARK: - Choice Card Button Style
struct ChoiceCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonPressAnimation(isPressed: configuration.isPressed)
    }
}

// MARK: - OR Divider (Shared Component)
struct ChoiceDivider: View {
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(BrewerColors.divider)
                .frame(height: 1)
            
            Text("OR")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            Rectangle()
                .fill(BrewerColors.divider)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}