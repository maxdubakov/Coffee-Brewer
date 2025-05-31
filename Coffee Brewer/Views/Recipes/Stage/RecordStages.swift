import SwiftUI
import CoreData

struct RecordStages: View {
    // MARK: - Environment & Bindings
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - View Model
    @StateObject private var recordViewModel: RecordStagesViewModel
    @StateObject private var stagesViewModel: StagesManagementViewModel
    
    // MARK: - State
    @State private var showingStagesManagement = false
    @State private var showingDemo = true
    @State private var demoStep = 0
    @State private var demoRecordedStages: [(time: Double, id: UUID, type: StageType)] = []
    
    // MARK: - Properties
    let formData: RecipeFormData
    let brewMath: BrewMathViewModel
    let existingRecipeID: NSManagedObjectID?
    
    // MARK: - Initialization
    init(formData: RecipeFormData, brewMath: BrewMathViewModel, context: NSManagedObjectContext, existingRecipeID: NSManagedObjectID?) {
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
                tapArea
                    
            }
            .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                SecondaryHeader(title: "Recorded Stages")
                    .padding(.horizontal, 15)
                
                RecordedStageScroll(
                    displayTimestamps: showingDemo && demoStep == 2 ? 
                        demoRecordedStages.map { (time: $0.time, id: $0.id, type: $0.type, isActive: false) } : 
                        recordViewModel.displayTimestamps,
                    currentElapsedTime: recordViewModel.elapsedTime,
                    onRemove: { index in
                        if !showingDemo {
                            recordViewModel.removeTimestamp(at: index)
                        }
                    }
                )
                .frame(height: 250)
            }
            .opacity(showingDemo && demoStep != 2 ? 0.1 : 1.0)
            
            Spacer()
            
            ZStack {
                // Control panel truly centered
                controlPanel
                    .opacity(showingDemo && demoStep < 3 ? 0.1: 1.0)
                
                // Done button positioned to the right
                HStack {
                    Spacer()
                        .frame(width: 120 + 80) // Width of control panel + spacing
                    
                    doneButton
                        .opacity(showingDemo && demoStep < 4 ? 0.1 : 1.0)
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
                .fill(BrewerColors.surface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            BrewerColors.caramel,
                            lineWidth: 2
                        )
                )
            
            if showingDemo && demoStep >= 1 {
                // Demo recording state
                VStack(spacing: 16) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 32))
                        .foregroundColor(BrewerColors.amber)
                    
                    Text("Tap to record 8 seconds of Fast pour")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            } else if let activeRecording = recordViewModel.activeRecording, !showingDemo {
                // Show recording state
                Button(action: {
                    recordViewModel.confirmRecording()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 32))
                            .foregroundColor(activeRecording.type == .fast ? BrewerColors.amber : BrewerColors.caramel)
                        
                        Text("Tap to record \(Int(recordViewModel.elapsedTime - activeRecording.startTime)) seconds of \(activeRecording.type.name) pour")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(BrewerColors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                HStack(spacing: 0) {
                    // Fast Pour
                    StageTypeButton(
                        type: .fast,
                        icon: "drop.fill",
                        color: BrewerColors.amber,
                        isRunning: true,
                        isFirstButton: true,
                        action: {
                            recordViewModel.startRecording(type: .fast)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                        isRunning: true,
                        isFirstButton: false,
                        action: {
                            recordViewModel.startRecording(type: .slow)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                }
            }
        }
        .frame(height: 140)
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
                    case 3:
                        demoStep4
                    case 4:
                        demoStep5
                    default:
                        EmptyView()
                    }
                }
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
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
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Start recording")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Tap to start the timer and begin recording your pour")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.39)
                
                Spacer()
            }
        }
    }
    
    private var demoStep2: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Save the pour")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)

                    Text("This will add an 8-second Fast pour to Recorded Stages")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.39)
                
                Spacer()
            }
        }
    }
    
    private var demoStep3: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()

                    Text("Recorded Stages")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Time between your pours is tracked automatically and added as a Wait stage")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            // Set up demo recorded stages
            demoRecordedStages = [
                (time: 8.0, id: UUID(), type: .fast),
                (time: 15.0, id: UUID(), type: .wait),
            ]
        }
    }
    
    private var demoStep4: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Text("Control your brew")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("Use pause/play to control timing, or restart to begin fresh")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(BrewerColors.amber)
                        .bounceAnimation()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var demoStep5: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(BrewerColors.amber)
                        .scaleAnimation()
                    
                    Text("Complete your recipe")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                    
                    Text("You can then adjust water amounts and timing for each stage")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.cream.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geometry.size.height * 0.35)
                
                Spacer()
            }
        }
    }
    
    private func advanceDemo() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if demoStep < 4 {
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
            context: context,
            existingRecipeID: nil
        )
    }
    .environment(\.managedObjectContext, context)
}
