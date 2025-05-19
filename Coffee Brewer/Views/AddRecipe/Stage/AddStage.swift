import SwiftUI
import CoreData

struct AddStage: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Bindings
    @Binding var focusedField: FocusedField?
    
    // MARK: - Observed Objects
    @ObservedObject var recipe: Recipe
    @ObservedObject var brewMath: BrewMathViewModel
    
    // MARK: - State
    @State private var selectedType: StageType = .fast
    @State private var seconds: Int16 = 10
    @State private var waterAmount: Int16 = 50
    
    // MARK: - Constants
    private var existingStage: Stage?
    
    init(
        recipe: Recipe,
        brewMath: BrewMathViewModel,
        focusedField: Binding<FocusedField?>,
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
        var amount = recipe.stagesArray.reduce(0) { $0 + $1.waterAmount }
        if isEditMode {
            amount -= existingStage?.waterAmount ?? 0;
        }
        return amount
    }
    
    private var remainingWater: Int16 {
        brewMath.water - totalWaterUsed - waterAmount
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
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Stage Type Picker
                        FormTypePicker(
                            title: "Stage Type",
                            field: .stageType,
                            options: StageType.allTypes,
                            selection: $selectedType,
                            focusedField: $focusedField
                        )

                        if (selectedType != .wait) {
                            FormKeyboardInputField(
                                title: "Water Amount (ml)",
                                field: .stageWaterAmount,
                                keyboardType: .numberPad,
                                valueToString: { String($0) },
                                stringToValue: { Int16($0) ?? 0 },
                                value: $waterAmount,
                                focusedField: $focusedField
                            )
                        }
                        
                        FormExpandableNumberField(
                            title: "Duration (seconds)",
                            range: Array(5...120),
                            formatter: { "\($0)s" },
                            field: .seconds,
                            value: $seconds,
                            focusedField: $focusedField,
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
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 20, leading: 18, bottom: 28, trailing: 18))
            }
            .scrollDismissesKeyboard(.immediately)
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
        .background(BrewerColors.background)
    }

    // MARK: - Methods
    private func saveOrUpdateStage() {
        if let stageToUpdate = existingStage {
            // Update existing stage
            stageToUpdate.type = selectedType.id
            stageToUpdate.seconds = seconds
            stageToUpdate.waterAmount = waterAmount
        } else {
            // Create new stage
            let newStage = Stage(context: viewContext)
            newStage.type = selectedType.id
            newStage.orderIndex = Int16(recipe.stagesArray.count)
            newStage.seconds = seconds
            newStage.waterAmount = waterAmount
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
    let brewMath = BrewMathViewModel(
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
        AddStage(recipe: recipe, brewMath: brewMath, focusedField: .constant(nil))
            .environment(\.managedObjectContext, context)
    }
}
