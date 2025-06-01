import SwiftUI
import CoreData

struct RecordStages: View {
    // MARK: - Environment & Bindings
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var onboardingState = OnboardingStateManager.shared
    
    // MARK: - View Model
    @StateObject private var recordViewModel: RecordStagesViewModel
    @StateObject private var stagesViewModel: StagesManagementViewModel
    
    // MARK: - State
    @State private var showingStagesManagement = false
    @StateObject private var recordingDemo = RecordingDemoOverlay()
    
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
                    .opacity(!onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep == 0 ? 0.1 : 1.0)
                tapArea
                    
            }
            .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                SecondaryHeader(title: "Recorded Stages")
                    .padding(.horizontal, 15)
                
                RecordedStageScroll(
                    displayTimestamps: !onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep == 2 ? 
                        recordingDemo.demoStages.map { (time: $0.time, id: $0.id, type: $0.type, isActive: false) } : 
                        recordViewModel.displayTimestamps,
                    currentElapsedTime: recordViewModel.elapsedTime,
                    onRemove: { index in
                        if onboardingState.hasSeenRecordingDemo {
                            recordViewModel.removeTimestamp(at: index)
                        }
                    }
                )
                .frame(height: 250)
            }
            .opacity(!onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep != 2 ? 0.1 : 1.0)
            
            Spacer()
            
            ZStack {
                // Control panel truly centered
                controlPanel
                    .opacity(!onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep < 3 ? 0.1: 1.0)
                
                // Done button positioned to the right
                HStack {
                    Spacer()
                        .frame(width: 120 + 80) // Width of control panel + spacing
                    
                    doneButton
                        .opacity(!onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep < 4 ? 0.1 : 1.0)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 90)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrewerColors.background.ignoresSafeArea())
        .overlay(
            RecordingDemoOverlayView(demo: recordingDemo)
        )
        .onAppear {
            // Set up demo dismiss handler
            recordingDemo.onDismiss = {
                // Demo dismissed
            }
        }
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
            
            if !onboardingState.hasSeenRecordingDemo && recordingDemo.demoStep >= 1 {
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
            } else if let activeRecording = recordViewModel.activeRecording, onboardingState.hasSeenRecordingDemo {
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
                        imageName: "drop.fast",
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
                        imageName: "drop.slow",
                        color: BrewerColors.amber,
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
        let imageName: String
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
                        SVGIcon(imageName, size: 20, color: isRunning ? color : BrewerColors.textSecondary)
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
            onRestart: recordViewModel.resetRecording,
            isDisabled: !recordViewModel.hasStartedRecording && onboardingState.hasSeenRecordingDemo
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
                .foregroundColor(recordViewModel.recordedTimestamps.isEmpty && onboardingState.hasSeenRecordingDemo ? BrewerColors.cream.opacity(0.4) : BrewerColors.cream)
                .frame(width: 60, height: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(recordViewModel.recordedTimestamps.isEmpty && onboardingState.hasSeenRecordingDemo ? BrewerColors.surface.opacity(0.5) : BrewerColors.surface.opacity(0.8))
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
