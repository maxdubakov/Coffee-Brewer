import SwiftUI
import CoreData

struct AddStageView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Bindings
    @Binding var focusedField: AddRecipe.FocusedField?
    
    // MARK: - Observed Objects
    @ObservedObject var recipe: Recipe
    @ObservedObject var brewMath: BrewMathViewModel
    
    // MARK: - State
    @State private var selectedType: StageType = .fast
    @State private var seconds: Int16 = 0
    @State private var waterAmount: Int16 = 0
    
    // MARK: - Constants
    private var existingStage: Stage?
    
    init(
        recipe: Recipe,
        brewMath: BrewMathViewModel,
        focusedField: Binding<AddRecipe.FocusedField?>,
        existingStage: Stage? = nil,
    ) {
        self.recipe = recipe
        self.brewMath = brewMath
        self.existingStage = existingStage
        self._focusedField = focusedField
        
        if let stage = existingStage {
            self._selectedType = State(initialValue: StageType.fromString(stage.type ?? "fast") ?? .fast)
            self._seconds = State(initialValue: stage.seconds)
            self._waterAmount = State(initialValue: stage.waterAmount)
        }
    }
    
    // MARK: - Computed Properties
    private var isEditMode: Bool {
        existingStage != nil
    }
    
    private var actionButtonTitle: String {
       isEditMode ? "Update Stage" : "Save Stage"
   }
    
    private var totalWaterUsed: Int16 {
        recipe.stagesArray.reduce(0) { $0 + $1.waterAmount }
    }
    
    private var remainingWater: Int16 {
        brewMath.water - totalWaterUsed
    }
    
    private var isWaterInputDisabled: Bool {
        selectedType == .wait
    }
    
    private var canSave: Bool {
        if selectedType == .wait {
            return seconds > 0
        } else {
            return waterAmount > 0 && waterAmount <= remainingWater
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                .padding(.leading, 18)
                Text("Add Stage")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(BrewerColors.textPrimary)
                    .padding(.vertical, 20)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 0) {
                        SecondaryHeader(title: "Stage Configuration")
                            .padding(.bottom, 10)
                        
                        // Stage Type Picker
                        FormTypePicker(
                            title: "Stage Type",
                            field: .stageType,
                            options: StageType.allTypes,
                            selection: $selectedType,
                            focusedField: $focusedField
                        )
                        
                        if selectedType == .wait {
                            FormExpandableNumberField(
                                title: "Duration (seconds)",
                                range: Array(5...120),
                                formatter: { "\($0)s" },
                                field: .seconds,
                                value: $seconds,
                                focusedField: $focusedField,
                            )
                        } else {
                            FormKeyboardInputField(
                                title: "Water Amount (ml)",
                                field: .stageWaterAmount,
                                keyboardType: .numberPad,
                                valueToString: { String($0) },
                                stringToValue: { Int16($0) ?? 0 },
                                value: $waterAmount,
                                focusedField: $focusedField
                            )
                            
                            if selectedType != .wait {
                                HStack {
                                    Spacer()
                                    Text("Remaining Water: \(remainingWater) ml")
                                        .font(.caption)
                                        .foregroundColor(
                                            waterAmount > remainingWater 
                                                ? Color.red 
                                                : BrewerColors.textSecondary
                                        )
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 20, leading: 18, bottom: 28, trailing: 18))
            }
            StandardButton(
                title: actionButtonTitle,
                action: saveOrUpdateStage,
                style: .primary,
            ).padding(18)
        }
        .onAppear {
            updateDefaultValues()
        }
        .onChange(of: selectedType) { _, _ in
            updateDefaultValues()
        }
    }

    // MARK: - Methods
    private func saveOrUpdateStage() {
        if let stageToUpdate = existingStage {
            // Update existing stage
            stageToUpdate.type = selectedType.id
            
            if selectedType == .wait {
                stageToUpdate.seconds = seconds
                stageToUpdate.waterAmount = 0
            } else {
                stageToUpdate.waterAmount = waterAmount
                stageToUpdate.seconds = 0
            }
        } else {
            // Create new stage
            let newStage = Stage(context: viewContext)
            newStage.type = selectedType.id
            newStage.orderIndex = Int16(recipe.stagesArray.count)
            
            if selectedType == .wait {
                newStage.seconds = seconds
                newStage.waterAmount = 0
            } else {
                newStage.waterAmount = waterAmount
                newStage.seconds = 0
            }
            recipe.addToStages(newStage)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save stage: \(error)")
        }
    }

    private func updateDefaultValues() {
        // Don't override values when in edit mode
        if existingStage != nil {
            return
        }
        
        switch selectedType.id {
        case "fast", "slow":
            if remainingWater < waterAmount {
                waterAmount = remainingWater > 0 ? remainingWater : 0
            }
        default:
            seconds = 30
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    var brewMath = BrewMathViewModel(
        grams: 18,
        ratio: 16.0,
        water: 288
    )
    
    // Create a sample recipe
    let recipe = Recipe(context: context)
    recipe.name = "Ethiopian Pour Over"
    recipe.grams = 18
    recipe.ratio = 16.0
    recipe.waterAmount = 288
    recipe.temperature = 94.0
    
    // Create an existing stage
    let stage = Stage(context: context)
    stage.type = "fast"
    stage.waterAmount = 50
    stage.orderIndex = 0
    stage.recipe = recipe
    
    return GlobalBackground {
        AddStageView(recipe: recipe, brewMath: brewMath, focusedField: .constant(nil))
            .environment(\.managedObjectContext, context)
    }
}
