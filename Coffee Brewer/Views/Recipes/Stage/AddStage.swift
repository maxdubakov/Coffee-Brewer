import SwiftUI
import CoreData

struct AddStage: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View Model
    @StateObject private var viewModel: AddStageViewModel
    
    // MARK: - Initialization
    init(viewModel: StagesManagementViewModel, existingStage: StageFormData? = nil) {
        _viewModel = StateObject(wrappedValue: AddStageViewModel(
            stagesViewModel: viewModel,
            existingStage: existingStage
        ))
    }
    
    var body: some View {
        FixedBottomLayout(
            contentPadding: EdgeInsets(top: 10, leading: 18, bottom: 0, trailing: 18),
            content: {
                VStack(alignment: .leading, spacing: 40) {
                    stageTypeSection
                    durationSection
                    waterSection
                    previewSection
                }
            },
            actions: {
                HStack(spacing: 16) {
                    StandardButton(
                        title: "Cancel",
                        action: { dismiss() },
                        style: .secondary
                    )
        
                    StandardButton(
                        title: viewModel.actionButtonTitle,
                        action: {
                            viewModel.saveOrUpdateStage { success in
                                if success {
                                    dismiss()
                                }
                            }
                        },
                        style: .primary
                    )
                }
            }
        )
        .alert(isPresented: $viewModel.showSaveError) {
            Alert(
                title: Text("Cannot Save Stage"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var stageTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SecondaryHeader(title: "Stage Type")
                .padding(.bottom, 4)
            
            FormTypePickerField(
                title: "Stage Type",
                field: .stageType,
                options: StageType.allTypes,
                selection: $viewModel.selectedType,
                focusedField: $viewModel.focusedField
            )
            
            Text(viewModel.stageTypeDescription)
                .font(.caption)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.horizontal, 4)
        }
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SecondaryHeader(title: "Duration")
                .padding(.bottom, 4)
            
            FormExpandableNumberField(
                title: "Duration (seconds)",
                range: Array(5...120),
                formatter: { "\($0)s" },
                field: .seconds,
                value: $viewModel.seconds,
                focusedField: $viewModel.focusedField
            )
        }
    }
    
    @ViewBuilder
    private var waterSection: some View {
        if viewModel.showWaterSection {
            VStack(alignment: .leading, spacing: 10) {
                SecondaryHeader(title: "Water")
                    .padding(.bottom, 4)
                
                FormKeyboardInputField(
                    title: "Water Amount (ml)",
                    field: .stageWaterAmount,
                    keyboardType: .numberPad,
                    valueToString: { String($0) },
                    stringToValue: { Int16($0) ?? 0 },
                    value: $viewModel.waterAmount,
                    focusedField: $viewModel.focusedField
                )
                
                HStack {
                    Text(viewModel.availableWaterText)
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.availableWaterColor)
                    
                    Spacer()
                    
                    Button("Use All") {
                        viewModel.useAllWater()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.caramel)
                    .opacity(viewModel.useAllButtonEnabled ? 1.0 : 0.5)
                    .disabled(!viewModel.useAllButtonEnabled)
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SecondaryHeader(title: "Preview")
                .padding(.bottom, 8)
            
            PourStage(
                stage: viewModel.createPreviewStage(),
                progressValue: viewModel.previewProgressValue(),
                total: viewModel.recipeWaterAmount,
            )
        }
        .padding(.bottom, 30)
    }
}
