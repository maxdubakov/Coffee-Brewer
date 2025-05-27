import SwiftUI

struct CurrentStageCard: View {
    // MARK: - Properties
    var stage: Stage
    var stageNumber: Int
    var stageProgress: Double
    
    // MARK: - Computed Properties
    private var stageType: String {
        return stage.type ?? "fast"
    }
    
    
    private var stageInstruction: String {
        if stageType == "wait" {
            return "Wait for \(stage.seconds)s"
        } else {
            return "Pour \(stage.waterAmount)ml"
        }
    }

    var body: some View {
        StageCardString(
            stageNumber: stageNumber,
            stageType: stageType,
            size: .large
        ) {
            VStack(alignment: .leading, spacing: 8) {
                StageInfo(
                    icon: stageType.stageIcon,
                    title: stageType.stageDisplayName,
                    color: stageType.stageColor,
                    iconSize: 18,
                    titleSize: 22
                )
                
                
                Text(stageInstruction)
                    .font(.system(size: 17))
                    .foregroundColor(BrewerColors.textSecondary)
                
                ProgressView(value: stageProgress)
                    .progressViewStyle(
                        PourProgressStyle(
                            height: 10,
                            cornerRadius: 5,
                            foregroundColor: stageType.stageColor
                        )
                    )
                    .padding(.top, 8)
            }.frame(height: 80)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Pour Progress Style
struct PourProgressStyle: ProgressViewStyle {
    var height: CGFloat
    var cornerRadius: CGFloat
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(BrewerColors.background.opacity(0.5))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [foregroundColor.opacity(0.7), foregroundColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, CGFloat(progress) * geometry.size.width), height: height)
            }
            .progressAnimation(value: progress)
        }
        .frame(height: height)
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
    
    let slowStage = Stage(context: context)
    slowStage.id = UUID()
    slowStage.type = "slow"
    slowStage.waterAmount = 138
    
    let waitStage = Stage(context: context)
    waitStage.id = UUID()
    waitStage.type = "wait"
    waitStage.seconds = 30
    
    return GlobalBackground {
        VStack(spacing: 20) {
            CurrentStageCard(
                stage: fastStage,
                stageNumber: 1,
                stageProgress: 0.1,
            )
            
            CurrentStageCard(
                stage: slowStage,
                stageNumber: 2,
                stageProgress: 0.2,
            )
            
            CurrentStageCard(
                stage: waitStage,
                stageNumber: 3,
                stageProgress: 0.95,
            )
        }
        .padding()
    }
}
