import SwiftUI
import CoreData

struct StageScroll: View {
    var recipe: Recipe
    @ObservedObject var timerViewModel: BrewTimerViewModel
    @Binding var currentStageIndex: Int

    var body: some View {
        let optionalIndexBinding = Binding<Int?>(
            get: { currentStageIndex },
            set: { newValue in
                if let value = newValue {
                    currentStageIndex = value
                }
            }
        )
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                    ForEach(recipe.stagesArray.indices, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(index == currentStageIndex ? BrewerColors.amber : BrewerColors.cream.opacity(0.3))
                            .scaleEffect(index == currentStageIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentStageIndex)
                    }
                }
                .padding(.top, 8)
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(recipe.stagesArray.indices, id: \.self) { index in
                        if index < recipe.stagesArray.count {
                            let stage = recipe.stagesArray[index]
                            CurrentStageCard(
                                stage: stage,
                                stageNumber: index + 1,
                                timeRemaining: timerViewModel.timeRemaining(forStage: index)
                            )
                            .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                            .opacity(index == currentStageIndex ? 1 : 0.25)
                            .animation(.easeInOut(duration: 0.3), value: currentStageIndex)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .frame(height: 200)
            .contentMargins(.vertical, 30, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: optionalIndexBinding)
        }
    }   
}
