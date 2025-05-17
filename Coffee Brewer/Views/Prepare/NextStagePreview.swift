import SwiftUI

struct NextStagePreview: View {
    // MARK: - Properties
    var stage: Stage
    var stageNumber: Int
    
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
    
    private var stageDetail: String {
        if stageType == "wait" {
            return "\(stage.seconds)s before next pour"
        } else {
            return "Pour \(stage.waterAmount)ml water"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Stage number
            ZStack {
                Circle()
                    .fill(BrewerColors.background)
                    .overlay(
                        Circle()
                            .strokeBorder(stageColor.opacity(0.4), lineWidth: 1.5)
                    )
                    .frame(width: 40, height: 40)
                
                Text("\(stageNumber)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
            }
            
            // Stage details
            VStack(alignment: .leading, spacing: 4) {
                Text(stageTitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary)
                
                Text(stageDetail)
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(stageColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let recipe = PersistenceController.preview.container.viewContext.registeredObjects
        .compactMap { $0 as? Recipe }
        .first!
    
    recipe.waterAmount = 288
    
    let waitStage = Stage(context: context)
    waitStage.type = "wait"
    waitStage.seconds = 30
    
    let fastPour = Stage(context: context)
    fastPour.type = "fast"
    fastPour.seconds = 30
    fastPour.waterAmount = 100
    
    return GlobalBackground {
        VStack(spacing: 20) {
            NextStagePreview(stage: waitStage, stageNumber: 2)
                .padding(.horizontal)
            
            NextStagePreview(stage: fastPour, stageNumber: 3)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
}
