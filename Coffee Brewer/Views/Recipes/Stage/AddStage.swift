import SwiftUI
import CoreData

struct AddStageView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                stageTypeSection
                durationSection
                waterSection
                previewSection
                actionButtons
            }
            .padding(EdgeInsets(top: 10, leading: 18, bottom: 40, trailing: 18))
        }
        .background(BrewerColors.background)
        .scrollDismissesKeyboard(.immediately)
        .alert(isPresented: $viewModel.showSaveError) {
            Alert(
                title: Text("Cannot Save Stage"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: viewModel.headerTitle)
            
            Text(viewModel.headerSubtitle)
                .font(.subheadline)
                .foregroundColor(BrewerColors.textSecondary)
        }
    }
    
    private var stageTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SecondaryHeader(title: "Stage Type")
                .padding(.bottom, 4)
            
            FormTypePicker(
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
        .padding(.bottom, 10)
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
            
            Text(viewModel.durationDescription)
                .font(.caption)
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.horizontal, 4)
        }
        .padding(.bottom, 30)
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
                        .font(.caption)
                        .foregroundColor(viewModel.availableWaterColor)
                    
                    Spacer()
                    
                    Button("Use All") {
                        viewModel.useAllWater()
                    }
                    .font(.caption)
                    .foregroundColor(BrewerColors.caramel)
                    .opacity(viewModel.useAllButtonEnabled ? 1.0 : 0.5)
                    .disabled(!viewModel.useAllButtonEnabled)
                }
                .padding(.horizontal, 4)
            }
            .padding(.bottom, 10)
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
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 30)
    }
    
    private var actionButtons: some View {
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
}
