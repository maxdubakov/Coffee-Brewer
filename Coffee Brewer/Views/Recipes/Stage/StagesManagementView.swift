import SwiftUI
import CoreData

struct StagesManagementView: View {
    // MARK: - Bindings
    @Binding var selectedTab: MainView.Tab
    
    // MARK: - State
    @State private var formData: RecipeFormData
    
    // MARK: - View Model
    @StateObject private var viewModel: StagesManagementViewModel
    
    // MARK: - Callbacks
    let onSaveComplete: (() -> Void)?
    let onFormDataUpdate: ((RecipeFormData) -> Void)?
    
    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel, selectedTab: Binding<MainView.Tab>, context: NSManagedObjectContext, existingRecipeID: NSManagedObjectID?, onSaveComplete: (() -> Void)? = nil, onFormDataUpdate: ((RecipeFormData) -> Void)? = nil) {
        _selectedTab = selectedTab
        _formData = State(initialValue: formData)
        _viewModel = StateObject(wrappedValue: StagesManagementViewModel(
            formData: formData,
            brewMath: brewMath,
            context: context,
            existingRecipeID: existingRecipeID
        ))
        self.onSaveComplete = onSaveComplete
        self.onFormDataUpdate = onFormDataUpdate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            editButtonSection
            addStageButton
            stagesContent
            Spacer()
            saveButton
        }
        .navigationDestination(isPresented: $viewModel.isAddingStage) {
            AddStageView(viewModel: viewModel)
        }
        .navigationDestination(item: $viewModel.stageBeingModified) { stage in
            AddStageView(viewModel: viewModel, existingStage: stage)
        }
        .alert(isPresented: $viewModel.showingSaveAlert) {
            Alert(
                title: Text("Save Recipe"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay {
            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.caramel))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .onChange(of: viewModel.formData) { _, newValue in
            formData = newValue
            onFormDataUpdate?(newValue)
        }
        .background(BrewerColors.background)
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: viewModel.headerTitle)
                .padding(.horizontal, 18)
            
            if !viewModel.headerSubtitle.isEmpty {
                Text(viewModel.headerSubtitle)
                    .font(.subheadline)
                    .foregroundColor(BrewerColors.textSecondary)
                    .padding(.horizontal, 18)
            }
        }
    }
    
    private var editButtonSection: some View {
        Group {
            if viewModel.hasStages {
                HStack {
                    WaterBalanceIndicator(
                        currentWater: viewModel.currentWater,
                        totalWater: viewModel.totalWater
                    )
                    .padding(.horizontal, 18)

                    Spacer()

                    Button(action: viewModel.toggleEditMode) {
                        Text(viewModel.editButtonTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(BrewerColors.caramel)
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
    }
    
    private var addStageButton: some View {
        AddButton(
            title: "Add Stage",
            action: viewModel.addStage
        )
        .padding(.horizontal, 18)
        .padding(.top, 24)
    }
    
    private var stagesContent: some View {
        Group {
            if viewModel.stages.isEmpty {
                emptyStageView
                    .padding(.horizontal, 18)
                    .padding(.vertical, 40)
            } else {
                stagesList
                    .padding(.top, 8)
            }
        }
    }
    
    private var stagesList: some View {
        List {
            ForEach(viewModel.stages, id: \.id) { stage in
                PourStage(
                    stage: stage,
                    progressValue: viewModel.progressValue(for: stage),
                    total: viewModel.totalWater,
                    minimize: viewModel.editMode == .active
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.editStage(stage)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        if let index = viewModel.stages.firstIndex(of: stage) {
                            viewModel.deleteStages(at: IndexSet([index]))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .contextMenu {
                    Button {
                        viewModel.stageBeingModified = stage
                    } label: {
                        Label("Edit Stage", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        if let index = viewModel.stages.firstIndex(of: stage) {
                            viewModel.deleteStages(at: IndexSet([index]))
                        }
                    } label: {
                        Label("Delete Stage", systemImage: "trash")
                    }
                    
                    if viewModel.stages.count > 1 {
                        Divider()
                        
                        if stage.orderIndex > 0 {
                            Button {
                                viewModel.moveStageUp(stage)
                            } label: {
                                Label("Move Up", systemImage: "arrow.up")
                            }
                        }
                        
                        if Int(stage.orderIndex) < viewModel.stages.count - 1 {
                            Button {
                                viewModel.moveStageDown(stage)
                            } label: {
                                Label("Move Down", systemImage: "arrow.down")
                            }
                        }
                    }
                }
            }
            .onMove(perform: viewModel.moveStages)
            .onDelete(perform: viewModel.deleteStages)
        }
        .environment(\.editMode, $viewModel.editMode)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyStageView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 30)
            Image(systemName: "drop.fill")
                .font(.system(size: 40))
                .foregroundColor(BrewerColors.caramel.opacity(0.5))
            
            Text("No brewing stages yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textPrimary)
            
            Text("Add your first brewing stage to continue")
                .font(.system(size: 16))
                .foregroundColor(BrewerColors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer(minLength: 30)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(BrewerColors.divider, lineWidth: 0.5)
                )
        )
    }
    
    private var saveButton: some View {
        StandardButton(
            title: "Save Recipe",
            iconName: "checkmark.circle.fill",
            action: {
                viewModel.saveRecipe { success in
                    if success {
                        onSaveComplete?()
                    }
                }
            },
            style: .primary
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 28)
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    var formData = RecipeFormData()
    formData.name = "Ethiopian Pour Over"
    formData.grams = 18
    formData.ratio = 16.0
    formData.waterAmount = 288
    formData.temperature = 94.0
    
    let brewMath = BrewMathViewModel(
        grams: formData.grams,
        ratio: formData.ratio,
        water: formData.waterAmount
    )
    
    return NavigationStack {
        GlobalBackground {
            StagesManagementView(
                formData: formData,
                brewMath: brewMath,
                selectedTab: .constant(.add),
                context: context,
                existingRecipeID: nil
            )
        }
    }
    .environment(\.managedObjectContext, context)
}
