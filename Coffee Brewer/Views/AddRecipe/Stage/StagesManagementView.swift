import SwiftUI
import CoreData

struct StagesManagementView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Observed Objects
    @ObservedObject var recipe: Recipe
    @ObservedObject var brewMath: BrewMathViewModel
    
    // MARK: - Bindings
    @Binding var selectedTab: MainView.Tab
    
    // MARK: - State
    @State private var focusedField: FocusedField? = nil
    @State private var editMode: EditMode = .inactive
    @State private var isAddingStage: Bool = false
    @State private var stageBeingModified: Stage? = nil
    @State private var showingSaveAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSaving: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                SectionHeader(title: "Recipe Stages")
                    .padding(.horizontal, 18)
                
                if recipe.stagesArray.isEmpty {
                    Text("Add brewing stages to your recipe")
                        .font(.subheadline)
                        .foregroundColor(BrewerColors.textSecondary)
                        .padding(.horizontal, 18)
                }
            }
            
            // Edit button if we have stages
            if !recipe.stagesArray.isEmpty {
                HStack {
                    WaterBalanceIndicator(
                        currentWater: recipe.totalStageWater,
                        totalWater: brewMath.water
                    )
                    .padding(.horizontal, 18)

                    Spacer()

                    Button(action: {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }) {
                        Text(editMode == .active ? "Done" : "Edit")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(BrewerColors.caramel)
                    }
                    .padding(.horizontal, 18)
                }
            }
            
            AddButton(
                title: "Add Stage",
                action: {
                    isAddingStage = true
                }
            )
            .padding(.horizontal, 18)
            .padding(.top, 24)
            
            // Stages list or empty state
            if recipe.stagesArray.isEmpty {
                emptyStageView
                    .padding(.horizontal, 18)
                    .padding(.vertical, 40)
            } else {
                stagesList
                    .padding(.top, 8)
            }
            Spacer()
            // Save button at the bottom
            StandardButton(
                title: "Save Recipe",
                iconName: "checkmark.circle.fill",
                action: saveRecipe,
                style: .primary
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .navigationDestination(isPresented: $isAddingStage) {
            AddStage(
                recipe: recipe,
                brewMath: brewMath,
                focusedField: $focusedField
            )
        }
        .navigationDestination(item: $stageBeingModified) { stage in
            AddStage(
                recipe: recipe,
                brewMath: brewMath,
                focusedField: $focusedField,
                existingStage: stage
            )
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Save Recipe"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay {
            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.caramel))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .background(BrewerColors.background)
        .onAppear {
            // If no stages exist yet, create a default one
            if recipe.stagesArray.isEmpty && !isAddingStage {
                recipe.createDefaultStage(context: viewContext)
                do {
                    try viewContext.save()
                } catch {
                    print("Error creating default stage: \(error)")
                }
            }
        }
    }
    
    // MARK: - View Components
    private var stagesList: some View {
        List {
            ForEach(recipe.stagesArray, id: \.id) { stage in
                PourStage(
                    stage: stage,
                    progressValue: recipe.totalStageWaterToStep(stepIndex: Int(stage.orderIndex)),
                    total: recipe.waterAmount,
                    minimize: editMode == .active
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    if editMode == .inactive {
                        stageBeingModified = stage
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteStages(at: IndexSet([recipe.stagesArray.firstIndex(of: stage)!]))
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .contextMenu {
                    Button {
                        stageBeingModified = stage
                    } label: {
                        Label("Edit Stage", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteStages(at: IndexSet([recipe.stagesArray.firstIndex(of: stage)!]))
                    } label: {
                        Label("Delete Stage", systemImage: "trash")
                    }
                    
                    if recipe.stagesArray.count > 1 {
                        Divider()
                        
                        // Move up action (if not first)
                        if stage.orderIndex > 0 {
                            Button {
                                moveStageUp(stage)
                            } label: {
                                Label("Move Up", systemImage: "arrow.up")
                            }
                        }
                        
                        // Move down action (if not last)
                        if Int(stage.orderIndex) < recipe.stagesArray.count - 1 {
                            Button {
                                moveStageDown(stage)
                            } label: {
                                Label("Move Down", systemImage: "arrow.down")
                            }
                        }
                    }
                }
            }
            .onMove(perform: moveStages)
            .onDelete(perform: deleteStages)
        }
        .environment(\.editMode, $editMode)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // Add these helper methods for context menu actions
    private func moveStageUp(_ stage: Stage) {
        guard stage.orderIndex > 0 else { return }
        
        let currentIndex = Int(stage.orderIndex)
        let newIndex = currentIndex - 1
        
        // Find the stage to swap with
        if let stageAbove = recipe.stagesArray.first(where: { $0.orderIndex == Int16(newIndex) }) {
            // Swap indices
            stageAbove.orderIndex = Int16(currentIndex)
            stage.orderIndex = Int16(newIndex)
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to move stage up: \(error)")
            }
        }
    }
    
    private func moveStageDown(_ stage: Stage) {
        let currentIndex = Int(stage.orderIndex)
        let newIndex = currentIndex + 1
        
        // Find the stage to swap with
        if let stageBelow = recipe.stagesArray.first(where: { $0.orderIndex == Int16(newIndex) }) {
            // Swap indices
            stageBelow.orderIndex = Int16(currentIndex)
            stage.orderIndex = Int16(newIndex)
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to move stage down: \(error)")
            }
        }
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
    
    // MARK: - Helper Methods
    private func moveStages(from source: IndexSet, to destination: Int) {
        var stages = recipe.stagesArray
        stages.move(fromOffsets: source, toOffset: destination)
        
        // Update order indices
        for (index, stage) in stages.enumerated() {
            stage.orderIndex = Int16(index)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to move stages: \(error)")
        }
    }
    
    private func deleteStages(at offsets: IndexSet) {
        let stagesToDelete = offsets.map { recipe.stagesArray[$0] }

        for stage in stagesToDelete {
            viewContext.delete(stage)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete stages: \(error)")
        }

        // Reindex remaining stages
        let remainingStages = recipe.stagesArray
        for (index, remainingStage) in remainingStages.enumerated() {
            remainingStage.orderIndex = Int16(index)
        }
    }
    
    private func saveRecipe() {
        // Validate stages before saving
        if recipe.stagesArray.isEmpty {
            alertMessage = "Please add at least one brewing stage"
            showingSaveAlert = true
            return
        }
        
        if !recipe.isStageWaterBalanced {
            alertMessage = "Stage water total (\(recipe.totalStageWater)ml) doesn't match recipe water amount (\(brewMath.water)ml). Would you like to adjust the recipe water amount?"
            showingSaveAlert = true
            return
        }
        
        // Show saving indicator
        isSaving = true
        
        // Small delay to ensure UI updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                // If this is a new recipe, set the last brewed date
                if recipe.lastBrewedAt == nil {
                    recipe.lastBrewedAt = Date()
                }
                
                // Update recipe with brew math values
                recipe.grams = brewMath.grams
                recipe.ratio = brewMath.ratio
                recipe.waterAmount = brewMath.water
                
                // Save to Core Data
                try viewContext.save()
                
                // Hide loading indicator
                isSaving = false
                
                // Navigate back to recipes tab
                selectedTab = .home
            } catch {
                // Handle error
                isSaving = false
                alertMessage = "Error saving recipe: \(error.localizedDescription)"
                showingSaveAlert = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let recipe = Recipe(context: context)
    recipe.id = UUID()
    recipe.name = "Ethiopian Pour Over"
    recipe.grams = 18
    recipe.ratio = 16.0
    recipe.waterAmount = 288
    recipe.temperature = 94.0
    
    let brewMath = BrewMathViewModel(
        grams: recipe.grams,
        ratio: recipe.ratio,
        water: recipe.waterAmount
    )
    
    // Sample stages
    func createStage(type: String, water: Int16 = 0, seconds: Int16 = 0, order: Int16) {
        let stage = Stage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterAmount = water
        stage.seconds = seconds
        stage.orderIndex = order
        stage.recipe = recipe
    }
    
        createStage(type: "fast", water: 50, seconds: 15, order: 0)
        createStage(type: "wait", seconds: 30, order: 1)
        createStage(type: "slow", water: 238, seconds: 90, order: 2)
    
    return NavigationStack {
        GlobalBackground {
            StagesManagementView(
                recipe: recipe,
                brewMath: brewMath,
                selectedTab: .constant(.add)
            )
        }
    }
    .environment(\.managedObjectContext, context)
}
