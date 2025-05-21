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
    @State private var seconds: Int16 = 15
    @State private var waterAmount: Int16 = 0
    @State private var showSaveError: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - Constants
    private var existingStage: Stage?
    
    init(
        recipe: Recipe,
        brewMath: BrewMathViewModel,
        focusedField: Binding<FocusedField?>,
        existingStage: Stage? = nil
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
            amount -= existingStage?.waterAmount ?? 0
        }
        return amount
    }
    
    private var remainingWater: Int16 {
        brewMath.water - totalWaterUsed
    }
    
    private var availableWater: Int16 {
        remainingWater
    }
    
    private var canSave: Bool {
        if selectedType == .wait {
            return seconds > 0
        } else {
            return waterAmount > 0 && waterAmount <= availableWater
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Stage Type Selection Header
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: isEditMode ? "Edit Stage" : "Add Stage")
                    
                    Text("Select the type of brewing stage and define its parameters")
                        .font(.subheadline)
                        .foregroundColor(BrewerColors.textSecondary)
                }
                
                // Stage Type Picker
                VStack(alignment: .leading, spacing: 10) {
                    SecondaryHeader(title: "Stage Type")
                        .padding(.bottom, 4)
                    
                    FormTypePicker(
                        title: "Stage Type",
                        field: .stageType,
                        options: StageType.allTypes,
                        selection: $selectedType,
                        focusedField: $focusedField
                    )
                    
                    Text(stageTypeDescription)
                        .font(.caption)
                        .foregroundColor(BrewerColors.textSecondary)
                        .padding(.horizontal, 4)
                }
                .padding(.bottom, 10)
                
                // Duration
                VStack(alignment: .leading, spacing: 10) {
                    SecondaryHeader(title: "Duration")
                        .padding(.bottom, 4)
                    
                    FormExpandableNumberField(
                        title: "Duration (seconds)",
                        range: Array(5...120),
                        formatter: { "\($0)s" },
                        field: .seconds,
                        value: $seconds,
                        focusedField: $focusedField
                    )
                    
                    if selectedType != .wait {
                        Text("How long this pour should take")
                            .font(.caption)
                            .foregroundColor(BrewerColors.textSecondary)
                            .padding(.horizontal, 4)
                    } else {
                        Text("How long to wait before the next stage")
                            .font(.caption)
                            .foregroundColor(BrewerColors.textSecondary)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.bottom, 30)
                
                if selectedType != .wait {
                    VStack(alignment: .leading, spacing: 10) {
                        SecondaryHeader(title: "Water")
                            .padding(.bottom, 4)
                        
                        FormKeyboardInputField(
                            title: "Water Amount (ml)",
                            field: .stageWaterAmount,
                            keyboardType: .numberPad,
                            valueToString: { String($0) },
                            stringToValue: { Int16($0) ?? 0 },
                            value: $waterAmount,
                            focusedField: $focusedField
                        )
                        
                        HStack {
                            Text("Available: \(availableWater) ml")
                                .font(.caption)
                                .foregroundColor(
                                    waterAmount > availableWater
                                    ? Color.red
                                    : BrewerColors.textSecondary
                                )
                            
                            Spacer()
                            
                            Button("Use All") {
                                waterAmount = availableWater
                            }
                            .font(.caption)
                            .foregroundColor(BrewerColors.caramel)
                            .opacity(availableWater > 0 ? 1.0 : 0.5)
                            .disabled(availableWater <= 0)
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.bottom, 10)
                }
                
                // Stage Preview
                VStack(alignment: .leading, spacing: 12) {
                    SecondaryHeader(title: "Preview")
                        .padding(.bottom, 8)
                    
                    createPreviewStage()
                        .padding(.horizontal, 4)
                }
                .padding(.bottom, 30)
                
                // Actions
                HStack(spacing: 16) {
                    StandardButton(
                        title: "Cancel",
                        action: {dismiss()},
                        style: .secondary
                    )

                    StandardButton(
                        title: actionButtonTitle,
                        action: saveOrUpdateStage,
                        style: .primary
                    )
                }
            }
            .padding(EdgeInsets(top: 10, leading: 18, bottom: 40, trailing: 18))
        }
        .background(BrewerColors.background)
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            updateDefaultValues()
        }
        .onChange(of: selectedType) { _, _ in
            updateDefaultValues()
        }
        .alert(isPresented: $showSaveError) {
            Alert(
                title: Text("Cannot Save Stage"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Computed Properties
    private var stageTypeDescription: String {
        switch selectedType.id {
        case "fast":
            return "Fast Pour: Quick addition of water, typically used for the bloom or to rapidly add water."
        case "slow":
            return "Slow Pour: Gradual addition of water, typically in a circular motion to extract flavor evenly."
        case "wait":
            return "Wait: Pause brewing to allow extraction, typically after bloom or between pours."
        default:
            return ""
        }
    }
    
    // MARK: - Helper Methods
    private func createPreviewStage() -> some View {
        let previewStage = Stage(context: viewContext)
        previewStage.id = UUID() // Temporary ID
        previewStage.type = selectedType.id
        previewStage.waterAmount = selectedType == .wait ? 0 : waterAmount
        previewStage.seconds = seconds
        previewStage.orderIndex = existingStage != nil ? existingStage!.orderIndex : Int16(recipe.stagesArray.count)
        
        return PourStage(
            stage: previewStage,
            progressValue: recipe.totalStageWater + (selectedType == .wait ? 0 : waterAmount)
        )
    }
    
    private func saveOrUpdateStage() {
        // Validate before saving
        if selectedType != .wait && (waterAmount <= 0 || waterAmount > availableWater) {
            errorMessage = "Water amount must be between 1 and \(availableWater) ml"
            showSaveError = true
            return
        }
        
        if seconds <= 0 {
            errorMessage = "Duration must be greater than 0 seconds"
            showSaveError = true
            return
        }
        
        if let stageToUpdate = existingStage {
            // Update existing stage
            stageToUpdate.type = selectedType.id
            stageToUpdate.seconds = seconds
            stageToUpdate.waterAmount = selectedType == .wait ? 0 : waterAmount
        } else {
            // Create new stage
            let newStage = Stage(context: viewContext)
            newStage.id = UUID()
            newStage.type = selectedType.id
            newStage.orderIndex = Int16(recipe.stagesArray.count)
            newStage.seconds = seconds
            newStage.waterAmount = selectedType == .wait ? 0 : waterAmount
            recipe.addToStages(newStage)
        }
        
        do {
            try viewContext.save()
            
            // Provide haptic feedback for success
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            dismiss()
        } catch {
            errorMessage = "Failed to save stage: \(error.localizedDescription)"
            showSaveError = true
        }
    }
    
    private func updateDefaultValues() {
        // Don't override values when in edit mode
        if existingStage != nil {
            return
        }
        
        switch selectedType.id {
        case "fast", "slow":
            if availableWater < waterAmount {
                waterAmount = availableWater > 0 ? availableWater : 0
            }
        case "wait":
            seconds = 30
        default:
            break
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
    recipe.id = UUID()
    recipe.name = "Ethiopian Pour Over"
    recipe.grams = 18
    recipe.ratio = 16.0
    recipe.waterAmount = 288
    recipe.temperature = 94.0
    
    // Create an existing stage
    let stage = Stage(context: context)
    stage.id = UUID()
    stage.type = "fast"
    stage.waterAmount = 50
    stage.orderIndex = 0
    stage.recipe = recipe
    
    return NavigationStack {
        AddStage(
            recipe: recipe,
            brewMath: brewMath,
            focusedField: .constant(nil)
        )
    }
    .environment(\.managedObjectContext, context)
}
