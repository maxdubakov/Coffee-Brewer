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
    
    private var stageColor: Color {
        switch stageType {
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
        switch stageType {
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
        switch stageType {
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
    
    private var stageInstruction: String {
        if stageType == "wait" {
            return "Wait for \(stage.seconds)s"
        } else {
            return "Pour \(stage.waterAmount)ml"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
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
                    .frame(width: 60, height: 60)
                    .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
                
                Text("\(stageNumber)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(BrewerColors.cream)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: stageIcon)
                        .foregroundColor(stageColor)
                        .font(.system(size: 18, weight: .medium))
                    
                    Text(stageTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                
                
                Text(stageInstruction)
                    .font(.system(size: 17))
                    .foregroundColor(BrewerColors.textSecondary)
                
                ProgressView(value: stageProgress)
                    .progressViewStyle(
                        PourProgressStyle(
                            height: 10,
                            cornerRadius: 5,
                            foregroundColor: stageColor
                        )
                    )
                    .padding(.top, 8)
            }.frame(height: 80)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(stageColor.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
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
            .animation(.easeInOut(duration: 0.3), value: progress)
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
