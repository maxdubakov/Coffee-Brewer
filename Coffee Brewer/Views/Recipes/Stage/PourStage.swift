import SwiftUI

struct PourStage: View {
    // MARK: - Properties
    let stage: StageFormData
    let progressValue: Int16
    let total: Int16
    var minimize: Bool = false
    
    // MARK: - Computed Properties
    private var pourType: String {
        return stage.type.id
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
        StageCardString(
            stageNumber: Int(stage.orderIndex) + 1,
            stageType: pourType,
            size: minimize ? .small : .normal,
            showBorder: true,
            content: {
                // Stage details
                VStack(alignment: .leading, spacing: 4) {
                    StageInfo(
                        icon: pourType.stageIcon,
                        title: pourType.stageDisplayName,
                        color: pourType.stageColor
                    )
                    
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
                                        gradient: Gradient(colors: [pourType.stageColor.opacity(0.7), pourType.stageColor]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: relativeProgressValue * 80, height: 6)
                            }
                        }
                    }
                }
            },
            trailing: {
                // Edit indicator (only when not in edit mode)
                if !minimize {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        PourStage(
            stage: StageFormData(from: previewStage(type: "fast", water: 36, seconds: 15)),
            progressValue: 36,
            total: 288
        )

        PourStage(
            stage: StageFormData(from: previewStage(type: "wait", water: 0, seconds: 30)),
            progressValue: 36,
            total: 288
        )

        PourStage(
            stage: StageFormData(from: previewStage(type: "slow", water: 100, seconds: 45)),
            progressValue: 136,
            total: 288,
            minimize: true
        )
    }
    .padding()
    .background(BrewerColors.background)
}

// Helper for preview
private func previewStage(type: String, water: Int16, seconds: Int16) -> Stage {
    let context = PersistenceController.preview.container.viewContext
    let stage = Stage(context: context)
    stage.type = type
    stage.waterAmount = water
    stage.seconds = seconds
    stage.orderIndex = 0
    return stage
}
