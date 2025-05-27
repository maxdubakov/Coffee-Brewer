import SwiftUI
import CoreData

struct RecordStages: View {
    // MARK: - Environment & Bindings
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: Main.Tab
    
    // MARK: - View Model
    @StateObject private var recordViewModel: RecordStagesViewModel
    @StateObject private var stagesViewModel: StagesManagementViewModel
    
    // MARK: - State
    @State private var showingStagesManagement = false
    @State private var showingDemo = true
    @State private var demoStep = 0
    
    // MARK: - Properties
    let formData: RecipeFormData
    let brewMath: BrewMathViewModel
    let existingRecipeID: NSManagedObjectID?
    
    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel, selectedTab: Binding<Main.Tab>, context: NSManagedObjectContext, existingRecipeID: NSManagedObjectID?) {
        self._selectedTab = selectedTab
        self.formData = formData
        self.brewMath = brewMath
        self.existingRecipeID = existingRecipeID
        
        self._recordViewModel = StateObject(wrappedValue: RecordStagesViewModel(
            formData: formData,
            brewMath: brewMath
        ))
        
        self._stagesViewModel = StateObject(wrappedValue: StagesManagementViewModel(
            formData: formData,
            brewMath: brewMath,
            context: context,
            existingRecipeID: existingRecipeID
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header and timer section
            VStack(spacing: 12) {
                timerSection
                    .opacity(showingDemo && demoStep < 1 ? 0.1 : 1.0)
                tapArea
                    .opacity(showingDemo && demoStep < 1 ? 0.1 : 1.0)
            }
            .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                SecondaryHeader(title: "Recorded Stages")
                    .padding(.horizontal, 15)
                
                RecordedStageScroll(
                    recordedTimestamps: recordViewModel.recordedTimestamps,
                    currentIndex: recordViewModel.recordedTimestamps.count - 1,
                    onRemove: { index in
                        recordViewModel.removeTimestamp(at: index)
                    }
                )
                .frame(height: 250)
            }
            .opacity(showingDemo && demoStep < 3 ? 0.0 : 1.0)
            
            Spacer()
            
            ZStack {
                // Control panel truly centered
                controlPanel
                    .opacity(showingDemo && demoStep < 0 ? 0.0: 1.0)
                
                // Done button positioned to the right
                HStack {
                    Spacer()
                        .frame(width: 120 + 80) // Width of control panel + spacing
                    
                    doneButton
                        .opacity(showingDemo && demoStep < 2 ? 0.1 : 1.0)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 90)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrewerColors.background.ignoresSafeArea())
        .overlay(
            showingDemo ? demoOverlay : nil
        )
        .navigationDestination(isPresented: $showingStagesManagement) {
            StagesManagement(
                formData: stagesViewModel.formData,
                brewMath: brewMath,
                selectedTab: $selectedTab,
                context: viewContext,
                existingRecipeID: existingRecipeID
            )
        }
    }
    
    private var timerSection: some View {
        VStack(spacing: 8) {
            Text(recordViewModel.elapsedTime.formattedTime)
                .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundColor(BrewerColors.textPrimary)
                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
        }
        .padding(.vertical, 20)
    }
    
    private var tapArea: some View {
        ZStack {
            // Background rounded rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(recordViewModel.isRunning ? BrewerColors.surface.opacity(0.8) : BrewerColors.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            recordViewModel.isRunning ? BrewerColors.caramel : BrewerColors.divider,
                            lineWidth: recordViewModel.isRunning ? 2 : 1
                        )
                )
            
            HStack(spacing: 0) {
                // Fast Pour
                StageTypeButton(
                    type: .fast,
                    icon: "drop.fill",
                    color: BrewerColors.amber,
                    isRunning: recordViewModel.isRunning,
                    isFirstButton: true,
                    action: {
                        if recordViewModel.isRunning {
                            recordViewModel.recordTap(type: .fast)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                )
                
                Rectangle()
                    .fill(BrewerColors.divider)
                    .frame(width: 1)
                    .padding(.vertical, 12)
                
                // Slow Pour
                StageTypeButton(
                    type: .slow,
                    icon: "drop",
                    color: BrewerColors.caramel,
                    isRunning: recordViewModel.isRunning,
                    isFirstButton: false,
                    action: {
                        if recordViewModel.isRunning {
                            recordViewModel.recordTap(type: .slow)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                )
                
                Rectangle()
                    .fill(BrewerColors.divider)
                    .frame(width: 1)
                    .padding(.vertical, 12)
                
                // Wait
                StageTypeButton(
                    type: .wait,
                    icon: "pause.circle",
                    color: BrewerColors.espresso,
                    isRunning: recordViewModel.isRunning,
                    isFirstButton: false,
                    action: {
                        if recordViewModel.isRunning {
                            recordViewModel.recordTap(type: .wait)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                )
            }
        }
        .frame(height: 140)
        .disabled(!recordViewModel.isRunning)
    }
    
    struct StageTypeButton: View {
        let type: StageType
        let icon: String
        let color: Color
        let isRunning: Bool
        let isFirstButton: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isRunning ? color.opacity(0.8) : BrewerColors.textSecondary.opacity(0.5))
                    
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(isRunning ? color : BrewerColors.textSecondary)
                        
                        Text(type.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isRunning ? BrewerColors.textPrimary : BrewerColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    
    private var controlPanel: some View {
        BrewControlPanel(
            isRunning: $recordViewModel.isRunning,
            onTogglePlay: recordViewModel.toggleTimer,
            onRestart: recordViewModel.resetRecording
        )
    }
    
    private var doneButton: some View {
        Button(action: {
            // Stop the timer
            if recordViewModel.isRunning {
                recordViewModel.toggleTimer()
            }
            
            // Generate stages from timestamps and update the form data
            let generatedStages = recordViewModel.generateStagesFromTimestamps()
            var updatedFormData = formData
            updatedFormData.stages = generatedStages
            stagesViewModel.formData = updatedFormData
            showingStagesManagement = true
        }) {
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(recordViewModel.recordedTimestamps.isEmpty && !showingDemo ? BrewerColors.cream.opacity(0.4) : BrewerColors.cream)
                .frame(width: 60, height: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(recordViewModel.recordedTimestamps.isEmpty && !showingDemo ? BrewerColors.surface.opacity(0.5) : BrewerColors.surface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            recordViewModel.recordedTimestamps.isEmpty ? BrewerColors.divider.opacity(0.5) : BrewerColors.caramel.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
        )
        .disabled(recordViewModel.recordedTimestamps.isEmpty)
    }
    
    
    // MARK: - Demo Overlay
    private var demoOverlay: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showingDemo = false
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.cream)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(BrewerColors.surface.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .strokeBorder(BrewerColors.cream.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Demo content based on step
                Group {
                    switch demoStep {
                    case 0:
                        demoStep1
                    case 1:
                        demoStep2
                    case 2:
                        demoStep3
                    default:
                        EmptyView()
                    }
                }
                
                Spacer()
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == demoStep ? BrewerColors.amber : BrewerColors.cream.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == demoStep ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: demoStep)
                    }
                }
                .padding(.bottom, 70)
            }
            .contentShape(Rectangle()) // Make entire area tappable
            .onTapGesture {
                advanceDemo()
            }
        }
        .transition(.opacity)
    }
    
    private var demoStep1: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Start the timer")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Tap the play button to begin timing your brew")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var demoStep2: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 20) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Record your stages")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("The timer is running and your first stage has begun.\n\nWhen you finish a stage (complete a pour or finish waiting), tap Fast, Slow, or Wait to record it.")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.40) // Relative positioning
                
                Spacer()
            }
        }
    }
    
    private var demoStep3: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(BrewerColors.amber)
                        .scaleAnimation()
                    
                    Text("Finish recording")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Tap Done when you've recorded all stages")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("You can then adjust water amounts and timing for each stage")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.cream.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.35) // Relative positioning
                
                Spacer()
            }
        }
    }
    
    private func advanceDemo() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if demoStep < 2 {
                demoStep += 1
            } else {
                showingDemo = false
            }
        }
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
        RecordStages(
            formData: formData,
            brewMath: brewMath,
            selectedTab: .constant(.add),
            context: context,
            existingRecipeID: nil
        )
    }
    .environment(\.managedObjectContext, context)
}
