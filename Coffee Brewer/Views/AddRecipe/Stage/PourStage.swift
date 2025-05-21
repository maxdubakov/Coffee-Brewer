import SwiftUI

struct PourStage: View {
    // MARK: - Properties
    @ObservedObject var stage: Stage
    let progressValue: Int16
    let total: Int16
    var minimize: Bool = false
    
    // MARK: - Computed Properties
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
        return CGFloat(progressValue) / CGFloat(total)
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
                
                Text("\(stage.orderIndex + 1)")
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
                
                HStack(spacing: 6) {
                    // Detail text (water amount or duration)
                    HStack(spacing: 4) {
                        if pourType != "wait" {
                            Image(systemName: "drop")
                                .font(.system(size: 10))
                                .foregroundColor(BrewerColors.textSecondary)
                        } else {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        Text(detailText)
                            .font(.system(size: 14))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    
                    // Duration for pour stages
                    if pourType != "wait" && stage.seconds > 0 && !minimize {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(BrewerColors.textSecondary)
                            
                            Text("\(stage.seconds)s")
                                .font(.system(size: 14))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                    }
                    
                    // Progress visualization - only show when not minimized
                    if pourType != "wait" && !minimize {
                        Spacer()
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(BrewerColors.inputBackground)
                                .frame(width: 80, height: 6)
                            
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [stageColor.opacity(0.7), stageColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: relativeProgressValue * 80, height: 6)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Edit indicator (only when not in edit mode)
            if !minimize {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, minimize ? 10 : 12)
        .padding(.horizontal, minimize ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(minimize ? stageColor.opacity(0.1) : stageColor.opacity(0.2), lineWidth: minimize ? 0.5 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: minimize)
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create sample stages
    let fastStage = Stage(context: context)
    fastStage.id = UUID()
    fastStage.type = "fast"
    fastStage.waterAmount = 50
    fastStage.seconds = 15
    fastStage.orderIndex = 0
    
    let waitStage = Stage(context: context)
    waitStage.id = UUID()
    waitStage.type = "wait"
    waitStage.seconds = 30
    waitStage.orderIndex = 1
    
    let slowStage = Stage(context: context)
    slowStage.id = UUID()
    slowStage.type = "slow"
    slowStage.waterAmount = 200
    slowStage.seconds = 90
    slowStage.orderIndex = 2
    
    return GlobalBackground {
        VStack(spacing: 16) {
            PourStage(
                stage: fastStage,
                progressValue: 50,
                total: 250,
            )
            
            PourStage(
                stage: waitStage,
                progressValue: 50,
                total: 250,
            )
            
            PourStage(
                stage: slowStage,
                progressValue: 250,
                total: 250,
            )
        }
        .padding()
    }
}
