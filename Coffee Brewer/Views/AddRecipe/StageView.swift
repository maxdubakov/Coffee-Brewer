import SwiftUI

struct StageView: View {
    // MARK: - Properties
    let stage: Stage
    let stageNumber: Int
    let progressValue: Int16
    
    // Computed properties for visual styling
    private var pourType: String {
        return stage.type ?? "fast"
    }
    
    private var stageColor: Color {
        switch pourType {
        case "fast":
            return BrewerColors.caramel
        case "slow":
            return BrewerColors.caramel
        case "wait":
            return BrewerColors.amber
        default:
            return BrewerColors.coffee
        }
    }
    
    private var stageIcon: String {
        switch pourType {
        case "fast":
            return "drop.fill"
        case "slow":
            return "drop.fill"
        case "wait":
            return "hourglass"
        default:
            return "questionmark.circle"
        }
    }
    
    private var stageTitle: String {
        switch pourType {
        case "fast":
            return "Fast Pour"
        case "slow":
            return "Slow Pour"
        case "wait":
            return "Wait"
        default:
            return "Unknown Stage"
        }
    }
    
    private var detailText: String {
        if pourType == "wait" {
            return "\(stage.seconds)s"
        } else {
            return "\(stage.waterAmount)ml"
        }
    }
    
    private var relativeProgressValue: CGFloat {
        return min(60, max(10, 60 * CGFloat(progressValue) / 300))

    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Stage number circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.espresso, stageColor.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Circle()
                            .strokeBorder(stageColor, lineWidth: 1.5)
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
                
                Text("\(stageNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
            }
            
            // Stage details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: stageIcon)
                        .foregroundColor(stageColor)
                        .font(.system(size: 14, weight: .medium))
                    Text(stageTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                
                HStack(spacing: 4) {
                    Text(detailText)
                        .font(.system(size: 15))
                        .foregroundColor(BrewerColors.textSecondary)
                    
                    // Progress visualization
                    if pourType != "wait" {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(BrewerColors.inputBackground)
                                .frame(width: 60, height: 6)
                            
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [stageColor.opacity(0.7), stageColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: relativeProgressValue, height: 6)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Edit button (optional)
            Image(systemName: "trash")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(stageColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
        )
    }
}
